# 
# Integration with GitHub, operating local filesystem.
#

require_relative '../lib/simple-openai-client.rb'
require_relative './config.rb'
require 'adspower-client'

previous_messages = [
  { "role" => "user", "content" => "Your name is Thelma." },
  #{ "role" => "user", "content" => "Create a new tag named 'Urgent' with a red color code for account 123." },
  #{ "role" => "user", "content" => "What is your name?" }
  #{ "role" => "user", "content" => "How many tags do I have in my configuration?" }
]

$functions = [
  {
    name: "run_command_in_local_computer",
    description: "Run a bash command in the local computer to perform any operation like accessing the local file system.",
    parameters: {
      type: :object,
      properties: {
        command: {
          type: :string,
          description: "A bash command.",
        },
      },
      required: ["command"],
    },    
  },
=begin
  {
    name: "search_files_in_local_filesystem",
    description: "Look into a folder and its subfolders for files containing one or more keywords in their content. Returns a list of matching file paths.",
    parameters: {
      type: "object",
      properties: {
        folder_path: {
          type: "string",
          description: "The path to the folder to search."
        },
        keywords: {
          type: "array",
          description: "List of keywords to look for in the file content. If any keyword appears in a file, it's considered a match.",
          items: { type: "string" }
        }
      },
      required: ["folder_path", "keywords"]
    }
  },
=end
  {
    name: "read_file_content",
    description: "Reads the content of one specific file and returns it so the AI can see it in the conversation context.",
    parameters: {
      type: "object",
      properties: {
        file_path: {
          type: "string",
          description: "The path to the file on the local filesystem."
        }
      },
      required: ["file_path"]
    }
  }
]

$callbacks = {
  :run_command_in_local_computer => lambda { |function_call_args|
    command = function_call_args["command"]
    ret = `#{command}`
    ret
  },
=begin
  search_files_in_local_filesystem: lambda { |function_call_args|
puts
puts "search_files_in_local_filesystem: #{function_call_args.to_s}"
    require 'shellwords'

    folder_path = function_call_args["folder_path"]
    keywords = function_call_args["keywords"] || []

    begin
      # Escape the folder path for safe usage in the shell
      folder_path_escaped = Shellwords.escape(folder_path)

      # Build a single combined pattern for grep: each keyword is escaped and joined by '|'
      pattern_escaped = keywords.map { |kw| Regexp.escape(kw) }.join("|")
      pattern_shell_escaped = Shellwords.escape(pattern_escaped)

      # Use grep to recursively search (-r) for any matching keyword (-E) in file content
      # -l lists only the filenames of matching files. 2>/dev/null ignores errors like "Permission denied".
      cmd = "grep -rilE #{pattern_shell_escaped} #{folder_path_escaped} 2>/dev/null"
puts cmd
      matching_files_str = `#{cmd}`
      matching_files = matching_files_str.split("\n").reject(&:empty?)

      { "matching_files" => matching_files }
    rescue => e
      { "error" => "Could not search files: #{e.message}" }
    end
  },
=end
  read_file_content: lambda { |function_call_args|
#puts
#puts "search_files_in_local_filesystem: #{function_call_args.to_s}"
    file_path = function_call_args["file_path"]
    begin
#binding.pry
      content = File.read(file_path)
      { "file_content" => content }
    rescue => e
      { "error" => "Error reading file: #{e.message}" }
    end
  }
}


$ai = OpenAIClient.new(
  api_key: OPENAI_API_KEY,
  model: MODEL,
  messages: previous_messages,
  functions: $functions,
  callbacks: $callbacks,
)

=begin
puts $ai.ask(
  "List the folders in ~/code1 please"
)
=end

$ai.console