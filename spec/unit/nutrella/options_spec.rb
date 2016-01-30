module Nutrella
  RSpec.describe Options do
    describe "task board name from options" do
      it "-t" do
        subject = options_parse("-t", "task_board_name")

        expect(subject.board_name).to eq("task_board_name")
      end

      it "--trello-board" do
        subject = options_parse("--trello-board", "task_board_name")

        expect(subject.board_name).to eq("task_board_name")
      end
    end

    describe "task board name from the current git branch" do
      it "-g" do
        allow(Git).to receive_message_chain(:open, :current_branch).and_return("9476_git_branch")

        subject = options_parse("-g")

        expect(subject.board_name).to eq("9476 Git Branch")
      end

      it "--current-git-branch" do
        allow(Git).to receive_message_chain(:open, :current_branch).and_return("9476_git_branch")

        subject = options_parse("--current-git-branch")

        expect(subject.board_name).to eq("9476 Git Branch")
      end

      it "with no options" do
        allow(Git).to receive_message_chain(:open, :current_branch).and_return("9476_git_branch")

        subject = options_parse

        expect(subject.board_name).to eq("9476 Git Branch")
      end
    end

    describe "initialization the configuration" do
      it "--init" do
        subject = options_parse("--init")

        expect(subject.init?).to eq(true)
      end
    end

    describe "display usage" do
      it "-h" do
        subject = options_parse("-h")

        expect(subject.show_usage?).to eq(true)
      end

      it "--help" do
        subject = options_parse("--help")

        expect(subject.show_usage?).to eq(true)
      end
    end

    describe "display version" do
      it "-v" do
        subject = options_parse("-v")

        expect(subject.show_version?).to eq(true)
        expect(subject.version).to eq(Nutrella::VERSION)
      end

      it "--version" do
        subject = options_parse("--version")

        expect(subject.show_version?).to eq(true)
        expect(subject.version).to eq(Nutrella::VERSION)
      end
    end

    def options_parse(*opts)
      Options.new(opts).tap(&:parse)
    end
  end
end
