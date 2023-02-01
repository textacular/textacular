require 'test_helper'
class Textacular::FullTestIndexerTest < BaseTest
  test "when Rails is not defined .stream_output points to STDOUT" do
    generator = Textacular::MigrationGenerator.new('filename', 'content')
    output_stream = nil
    generator.stream_output do |io|
      output_stream = io
    end
    assert_equal STDOUT, output_stream
  end

  setup_rails = Proc.new do
    module ::Rails
      # Stub this out, sort of.
      def self.root
        File.join('.', 'fake_rails')
      end
    end
  end

  def teardown_rails
    Object.send(:remove_const, :Rails)
    FileUtils.rm_rf(File.join('.', 'fake_rails'))
  end

  test "when Rails is defined .stream_output points to a properly named migration file" do
    setup_rails.call
    now = Time.now
    expected_file_name = "./fake_rails/db/migrate/#{now.strftime('%Y%m%d%H%M%S')}_file_name.rb"
    output_stream = nil
    generator = Textacular::MigrationGenerator.new('file_name', 'content')
    generator.stream_output(now) do |io|
      output_stream = io
    end
    assert_equal expected_file_name, output_stream.path
    teardown_rails
  end

  test "when Rails is defined .stream_output generates the right SQL" do
    content = "content\n" #newline automatically added
    output = StringIO.new
    generator = Textacular::MigrationGenerator.new('file_name', content)
    generator.instance_variable_set(:@output_stream, output)
    generator.generate_migration
    assert_equal content, output.string 
  end
end
