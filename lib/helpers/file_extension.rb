# frozen_string_literal: true

require "fileutils"
class File
  def self.write_to_file(path, data)
    open_file_with_data(path, data)
  end

  def self.delete_directory(path: string)
    return unless Dir.exist?(path)

    FileUtils.rm_r(path)
  end

  def self.delete_file(path: string)
    return unless exist?(path)

    delete(path)
  end

  def self.create_directory(path: string)
    FileUtils.mkdir_p(path) unless Dir.exist?(path)
  end

  def self.create_new_file_with_data(path, data)
    File.open(path, "w") do |f|
      f.write(data)
    end
  end

  def self.add_to_file_data(path, data)
    File.open(path, "a") do |f|
      f.write(data)
    end
  end

  def self.create_or_add_to_file_data(path, data)
    if exist?(path)
      data = data.empty? ? "" : "\n#{data}"
      add_to_file_data(path, data)
    else
      create_new_file_with_data(path, data)
    end
  end

  def self.read_file(path)
    File.open(path, "r") do |f|
      data = f.read.to_s
      return data || ""
    end
  end

  def self.open_file_with_data(path, data)
    File.open(path, "w") do |f|
      f.write(data)
    end
  end
end
