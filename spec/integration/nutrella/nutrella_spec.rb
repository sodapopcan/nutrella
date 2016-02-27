module Nutrella
  RSpec.describe "Nutrella" do
    let(:board_name) { "My Board" }
    let(:url) { "board_url" }
    let(:board) { instance_double(Trello::Board, id: "id", name: board_name, url: url) }

    before do
      allow(TaskBoardName).to receive(:from_git_branch).and_return(board_name)
    end

    it "creates initial configuration file" do
      create_command do |subject|
        expect { subject.run }.to output(/you don't have a config file/).to_stderr.and(raise_error(SystemExit))
        expect_contents(subject.configuration_filename, initial_configuration)
      end
    end

    it "looks up an existing task board" do
      create_command do |subject|
        create_sample(subject.configuration_filename)
        trello_search(board_name, search_result: [board])

        expect(subject).to receive(:system).with("open #{url}")

        subject.run
      end
    end

    it "creates a task board" do
      create_command do |subject|
        create_sample(subject.configuration_filename)
        trello_search(board_name, search_result: [])

        expect(Trello::Board).to receive(:create)
          .with(name: board_name, organization_id: TaskBoard::NULOGY_ORGANIZATION_ID)
          .and_return(board)

        expect_any_instance_of(Trello::Client).to receive(:put)
          .with("/boards/#{board.id}", "prefs/permissionLevel=org")

        expect(subject).to receive(:system).with("open #{url}")

        subject.run
      end
    end

    def create_command
      Dir.mktmpdir { |home_dir| yield Command.new(home_dir) }
    end

    def trello_search(board_name, search_result:)
      allow(Trello::Action).to receive(:search)
        .with(board_name, anything)
        .and_return("boards" => search_result)
    end

    def create_sample(configuration_filename)
      File.write(configuration_filename, <<-SAMPLE.strip_heredoc)
        # Trello Developer API Keys
        key: developer_key
        secret: developer_secret
        token: developer_token
      SAMPLE
    end

    def expect_contents(configuration_filename, expected_configuration)
      expect(File.exist?(configuration_filename)).to eq(true)
      expect(File.read(configuration_filename)).to eq(expected_configuration)
    end

    def initial_configuration
      <<-YAML.strip_heredoc
        # Trello Developer API Keys
        key: <your developer key>
        secret: <your developer secret>
        token: <your developer token>
      YAML
    end
  end
end
