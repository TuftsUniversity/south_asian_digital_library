corpora
===========================

1. Clearing background indexing jobs from the queue:  You can invoke rake jobs:clear to delete all jobs in the queue.
2. Importing Data:
  rake tufts:sadl:populate_people_from_authority_file['/Documents/workspace/south_asian_digital_library/spec/fixtures/people_20140114.csv']
  rake tufts:sadl:populate_concepts_from_authority_file['/Documents/workspace/south_asian_digital_library/spec/fixtures/concepts_20140114.csv']
