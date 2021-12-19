require 'yaml'

# Helper class to load yaml config files
class ConfigLoader
  def initialize(path)
    load_config_data(path)
  end

  def [](name)
    config_for(name)
  end

  def config_for(name)
    @config_data[name]
  end

  private

  def load_config_data(path)
    config_file_path = path
    begin
      config_file_contents = File.read(config_file_path)
    rescue Errno::ENOENT
      warn 'missing config file'
      raise
    end
    @config_data = YAML.safe_load(config_file_contents)
  end
end
