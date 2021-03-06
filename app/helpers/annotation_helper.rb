require 'active_support/all'
require 'rsolr'
require 'set'

# code to help with annotations and getting annotation data to the client
module AnnotationHelper

  # annotate key words with a link to javascript function to display linked item
  def self.annotate_chunks(chunks, records, javascript_function)
    regexp = create_regexp(records)
    replacement_text =  "<a href='javascript:" + javascript_function + "(\"\0\")'>\0</a>"
    chunks.each do |chunk|
      text = chunk.text
      changed_text = text.gsub(regexp, replacement_text)
      chunk.text = changed_text
    end
  end

  # create a regular expression to match the passed array of people or concepts, etc.
  # currently, this is done on the client in javascript, not here
  def self.create_regexp(records)
    pattern = "\b("
    records.each do |record|
      name = record.name
      pattern << name
      unless record == records.last
        pattern << '|'
      end
    end
    pattern << ")\b"
    return RegExp.new pattern
  end

  # create a javascript function that returns an array of hashtables
  #   with all the people data.
  def self.show_people(people)
    result = people.to_json
    result = "function initPeople () {return " + result + '};'
    return result
  end

  # create a javascript function that returns an array of hashtables
  #   with all the concept data.
  def self.show_concepts(concepts)
    result = concepts.to_json
    result = "function initConcepts () {return " + result + '};'
    return result
  end

  # create a javascript function returns an array of hashtables
  #   with all the places data.
  def self.show_places(places)
    result = places.to_json
    result = "function initPlaces () {return" + result + '};'
    return result
  end

  # query Solr to get all occurrences of the the passed term
  # return the docs in the solr response
  # used to obtain all the transcript segments for a term
  # will this scale?  what if the passed term is referenced hundreds of times?
  # what is the default number of items Solr will return?
  def self.get_references(thing)
    solr_connection = ActiveFedora.solr.conn
    thing_q = 'thing_ssim:"' + thing + '"'
    response = solr_connection.get 'select', :params => {:q => thing_q,:rows=>'10000000'}

    docs = response['response']['docs']
    return docs
  end

  # iterate over the Solr docs and compute summary info needed for UI
  # return an array of hashes, each hash contains title, id and occurrence count
  # filter out data for passed pid, they are internal references
  def self.summarize_external_references(pid, references)
    return_value = {}
    references.each{ |reference|
      lecture_id = reference['pid_ssi']
      id = reference['id']
      if lecture_id == id
	next 
      end
      if (lecture_id != pid)
        summary = return_value[lecture_id]
        if (summary.nil?)
          title = reference['title_tesim'][0]
          title.slice! "Excerpt from " if title[/^Excerpt from/]

          #get the collection information
          solr_connection = ActiveFedora.solr.conn
          q = 'id:'+lecture_id
          response = solr_connection.get 'select', :params => {:q => q,:rows=>'1',:fl => 'corpora_collection_tesim'}
          collection = response['response']['docs'][0]['corpora_collection_tesim']
          #logger.error "Collection: #{collection}"
          #logger.error "q: #{q}"
          ##logger.error "response : #{response['response']}"
          #logger.error "reference : #{reference}"
          #logger.error  "Text: #{reference['text_tesim']}"
          #logger.error "Display Time: #{reference['display_time_ssim']}"
          #logger.error "Time: #{reference['time_ssim']}"
          #logger.error "Pid: #{reference['pid_ssim']}"
	  text_array = reference['text_tesim']
          bubble = [{text: summarize_text(text_array), display_time: reference['display_time_ssim'][0], time: reference['time_ssim'][0], pid: reference['pid_ssi']}]

          summary = {count: 1, title: title, id: lecture_id, collection: collection, bubble: bubble}

          return_value[lecture_id] = summary
        else
          #logger.error "Collection: #{collection}"
          ##logger.error "q: #{q}"
          #logger.error "reference : #{reference}"
          #logger.error  "Text: #{reference['text_tesim']}"
          ##logger.error "Display Time: #{reference['display_time_ssim']}"
          #logger.error "Time: #{reference['time_ssim']}"
          #logger.error "Pid: #{reference['pid_ssim']}"
	  text_array = reference['text_tesim']
          summary[:count] = summary[:count] + 1
          summary[:bubble] << {text: summarize_text(reference['text_tesim']), display_time: reference['display_time_ssim'][0], time: reference['time_ssim'][0], pid: reference['pid_ssi']}

        end
      end
    }
    return return_value.values.sort{ |a,b| a[:count] <=> b[:count] }.reverse
  end

  def self.summarize_text(text_array)
          #logger.error  "Caller: #{caller}"
          #logger.error  "Text Array: #{text_array}"
    text_array ||= []
    all_bubble_text = ''

    if text_array.size < 2
      all_bubble_text = text_array[0]
    else
      text_array.each {|paragraph|
        all_bubble_text += '<div style="margin-bottom:10px">' + paragraph + '</div>'
      }
    end
    all_bubble_text
  end
  # iterate over Solr docs and compute summary for references to the passed pid
  def self.summarize_internal_references(pid, references)
    return_value = []
    references.each{ | reference|
      current_pid = reference['pid_ssi']
      if (pid == current_pid)
        id = reference['id']
        dash = id.rindex '-'
        unless dash.nil?
          segment_number = id[dash + 1, id.size]
          segment_number = segment_number.tr(' ','_')
          text = summarize_text(reference['text_tesim'])
          start_in_milliseconds = reference['time_ssim']
          display_time_ssim = reference['display_time_ssim']
          summary = {segmentNumber: segment_number, text: text, start_in_milliseconds: start_in_milliseconds,
                   display_time_ssim: display_time_ssim}
          return_value << summary
        end
      end
    }
    return return_value
  end

  # return a flat list of the concepts, places and people appearing in the passed pid
  def self.get_terms_flat(pid)
    return_value = Set.new
    solr_connection = ActiveFedora.solr.conn
    response = solr_connection.get 'select', :params => {:q => 'pid_ssi:' + pid, :rows=>'10000000',:fl => 'thing_ssim'}

    docs = response['response']['docs']
    docs.each { |current_doc|
      terms = current_doc['thing_ssim']
      terms.each { |term|
        return_value << term
      }
    }
    return return_value
  end

  # query solr and return all the concepts, people and places for the passed interview
  # return value is a hash with keys :concepts, :people and :places, the values are set objects
  def self.get_terms(pid)
    solr_connection = ActiveFedora.solr.conn
    # first, get all the Solr records for this pid
    response = solr_connection.get 'select', :params => {:q => 'pid_ssi:' + pid, :rows=>'10000000',:fl => 'concepts_ssim, person_ssim, place_ssim'}
    docs = response['response']['docs']

    concepts = Set.new
    people = Set.new
    places = Set.new

    # iterate over Solr documents adding found concepts, people and places to their corresponding sets
    docs.each { |current_doc|
      current_concepts = current_doc['concepts_ssim']
      unless current_concepts.nil?
        current_concepts.each { | concept |
          concepts << concept unless concept == 'concept'}
      end
      current_people = current_doc['person_ssim']
      unless current_people.nil?
        current_people.each { | person |
        people << person}
      end
      current_places = current_doc['place_ssim']
      unless current_places.nil?
        current_places.each { | place |
          places << place
        }
      end
    }
    # return a hash with the concepts, people and places
    return_value = {:concepts => concepts, :people => people, :places => places}
    return return_value
  end
end
