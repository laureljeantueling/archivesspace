Sequel.migration do
  up do

    create_table(:whosaidhello) do
      primary_key :id

      Integer :accession_id, :null => true

      String :name, :null => false

      apply_mtime_columns
    end


    alter_table(:whosaidhello) do
#      add_foreign_key([:repo_id], :repository, :key => :id)

      add_foreign_key([:accession_id], :accession, :key => :id)
    end

  end

  down do
    drop_table(:whosaidhello)
  end

end
