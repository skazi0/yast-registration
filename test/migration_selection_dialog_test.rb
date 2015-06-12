#! /usr/bin/env rspec

require_relative "spec_helper"

describe Registration::UI::MigrationSelectionDialog do
  subject { Registration::UI::MigrationSelectionDialog }
  let(:migration_products) { load_yaml_fixture("migration_to_sles12_sp1.yml") }

  describe ".run" do
    it "displays the possible migrations and returns the user input" do
      # user pressed the "Abort" button
      expect(Yast::UI).to receive(:UserInput).and_return(:abort)

      # check the displayed content
      expect(Yast::Wizard).to receive(:SetContents) do |_title, content, _help, _back, _next|
        # do a simple check: convert the term to a String
        expect(content.to_s).to include("`item (`id (0), \"SLES-12.1-x86_64\")")
      end

      expect(subject.run(migration_products)).to eq(:abort)
    end

    it "saves the entered values when clicking Next" do
      # user pressed the "Abort" button
      expect(Yast::UI).to receive(:UserInput).and_return(:next)
      expect(Yast::UI).to receive(:QueryWidget).with(:migration_targets, :CurrentItem)
        .and_return(0).twice
      expect(Yast::UI).to receive(:QueryWidget).with(:manual_repos, :Value).and_return(true)

      dialog = subject.new(migration_products)
      expect(dialog.run).to eq(:next)

      # check the saved values
      expect(dialog.selected_migration).to eq(migration_products.first)
      expect(dialog.manual_repo_selection).to eq(true)
    end
  end
end
