module Pod
  class Command
    class Search < Command
      self.summary = 'Search pods'

      self.description = <<-DESC
        Searches for pods, ignoring case, whose name matches `QUERY'. If the
        `--full' option is specified, this will also search in the summary and
        description of the pods.
      DESC

      self.arguments = '[QUERY]'

      def self.options
        [[
          "--full",  "Search by name, summary, and description",
          "--stats", "Show additional stats (like GitHub watchers and forks)"
        ]].concat(super)
      end

      def initialize(argv)
        @full_text_search = argv.flag?('full')
        @stats = argv.flag?('stats')
        @query = argv.shift_argument
        super
      end

      def validate!
        super
        help! "A search query is required." unless @query
      end

      def run
        sets = SourcesManager.search_by_name(@query.strip, @full_text_search)
        sets.each do |set|
          begin
            UI.pod(set, (@stats ? :stats : :normal))
          rescue DSLError => e
            UI.warn "Skipping `#{set.name}` because the podspec contains errors."
          end
        end
      end
    end
  end
end
