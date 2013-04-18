class ArchivesSpaceService < Sinatra::Base

  Endpoint.post('/repositories/:repo_id/batch_imports')
    .description("Import a batch of records")
    .params(["batch_import", JSONModel(:batch_import), "The batch of records", :body => true],
            ["repo_id", :repo_id])
    .request_context(:create_enums => true)
    .permissions([:update_archival_record])
    .returns([200, :created],
             [400, :error],
             [409, :error]) \
  do
    records = params[:batch_import]
    batch = Batch.new(records)
    success = false

    ticker = ProgressTicker.new(:frequency_seconds => 2) do |progress_ticker|
      begin
        DB.open do
          handle_import(batch, progress_ticker)
        end
        success = true
      ensure
        progress_ticker.finished(:total_records => (success ? records['batch'].length : 0))
      end
    end

    [200, {"Content-Type" => "text/plain"}, ticker]
  end

end
