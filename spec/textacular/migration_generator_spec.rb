RSpec.describe Textacular::MigrationGenerator do
  describe ".stream_output" do
    context "when Rails is not defined" do
      subject do
        Textacular::MigrationGenerator.new('filename', 'content')
      end

      it "points to STDOUT" do
        output_stream = nil

        subject.stream_output do |io|
          output_stream = io
        end

        expect(output_stream).to eq(STDOUT)
      end
    end

    context "when Rails is defined" do
      before do
        module ::Rails
          # Stub this out, sort of.
          def self.root
            File.join('.', 'fake_rails')
          end
        end
      end

      after do
        Object.send(:remove_const, :Rails)
        FileUtils.rm_rf(File.join('.', 'fake_rails'))
      end

      let(:now) do
        Time.now
      end

      subject do
        Textacular::MigrationGenerator.new('file_name', 'content')
      end

      it "points to a properly names migration file" do
        expected_file_name = "./fake_rails/db/migrate/#{now.strftime('%Y%m%d%H%M%S')}_file_name.rb"

        output_stream = nil

        subject.stream_output(now) do |io|
          output_stream = io
        end

        expect(output_stream.path).to eq(expected_file_name)
      end
    end

    it "generates the right SQL" do
      content = "content\n" #newline automatically added
      output = StringIO.new

      generator = Textacular::MigrationGenerator.new('file_name', content)
      generator.instance_variable_set(:@output_stream, output)

      generator.generate_migration

      expect(output.string).to eq(content)
    end
  end
end
