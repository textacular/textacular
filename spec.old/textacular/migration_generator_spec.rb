require 'spec_helper'

class MigrationGeneratorTest < Test::Unit::TestCase
  context ".stream_output" do
    context "when Rails is not defined" do
      setup do
        @generator = Textacular::MigrationGenerator.new('filename', 'content')
      end

      should "point to stdout" do
        @output_stream = nil

        @generator.stream_output do |io|
          @output_stream = io
        end

        assert_equal(@output_stream, $stdout)
      end
    end

    context "When Rails IS defined" do
      setup do
        module ::Rails
          # Stub this out, sort of.
          def self.root
            File.join('.', 'fake_rails')
          end
        end

        @now = Time.now
        @filename = 'filename'
        @generator = Textacular::MigrationGenerator.new(@filename, 'content')
      end

      teardown do
        Object.send(:remove_const, :Rails)
        FileUtils.rm_rf(File.join('.', 'fake_rails'))
      end

      should "point to a properly named migration file" do
        expected_file_name = "./fake_rails/db/migrate/#{@now.strftime('%Y%m%d%H%M%S')}_#{@filename}.rb"

        @output_stream = nil

        @generator.stream_output(@now) do |io|
          @output_stream = io
        end

        assert_equal(expected_file_name, @output_stream.path)
      end
    end
  end

  context "the content of the migration" do
    setup do
      @migration_content = "content\n" # newline automatically added
      @generator = Textacular::MigrationGenerator.new('filename', @migration_content)
      @output = StringIO.new
      @generator.instance_variable_set(:@output_stream, @output)
    end

    should "generate the right sql" do
      @generator.generate_migration

      assert_equal(@migration_content, @output.string)
    end
  end
end
