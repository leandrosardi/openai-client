# Reference:
# - https://platform.openai.com/docs/guides/function-calling/supported-models
#

require 'net/http'
require 'uri'
require 'json'
require 'colorize'

class GeminiClient
    attr_accessor :api_key, :model, :messages, :functions, :callbacks, :version
  
    def initialize(api_key:, model:, messages: [], functions: [], callbacks: [], version: 'v2')
      self.api_key = api_key
      self.model = model
      self.messages = messages
      self.functions = functions
      self.callbacks = callbacks
      self.version = version
    end
  
    # Return an array with the available models
    def models
      uri = URI("https://api.gemini.google.com/v1/models") # Changed API endpoint
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
  
      # Create a GET request instead of POST
      request = Net::HTTP::Get.new(uri.request_uri, {
        "Authorization" => "Bearer #{self.api_key}",
        "Content-Type" => "application/json"
        # Removed "OpenAI-Beta" header as it's typically not required
      })
  
      response = http.request(request)
  
      if response.is_a?(Net::HTTPSuccess)
        parsed_response = JSON.parse(response.body)
        # Extract and return the list of models
        parsed_response['data'].map { |model| model['id'] }
      else
        raise "Error: #{response.code} #{response.message}"
        #puts response.body
        #[]
      end
    rescue JSON::ParserError => e
      raise "Failed to parse JSON response: #{e.message}"
      #[]
    rescue StandardError => e
      raise "An error occurred: #{e.message}"
      #[]
    end # models


    # Ask something to GPT.
    #
    # @param s               [String]   The user prompt
    # @param context         [Array<Hash>]  Additional messages to prepend
    # @param function_to_call[String,nil]  Name of the function you want GPT to call
    # @param function_args  [Hash,nil]     Arguments to pass into the function call
    #
    # @return [String] the assistant’s reply (or function result)
    def ask(s, context: [], function_to_call: nil, function_args: nil)
        uri = URI("https://api.gemini.google.com/v1/chat/completions") # Changed API endpoint

        # build message history
        self.messages += context
        self.messages << { "role" => "user", "content" => s }

        # base request
        request_body = {
            "model"    => self.model,
            "messages" => self.messages
        }

        if functions.any?
            request_body["functions"] = functions
            
            # force GPT to call a specific function…
            if function_to_call
                if function_args
                    # pass args as a JSON object, not a string
                    request_body["function_call"] = {
                        "name"      => function_to_call,
                        "arguments" => function_args.to_json
                    }
                else
                    request_body["function_call"] = { "name" => function_to_call }
                end
            end
        end

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        req = Net::HTTP::Post.new(uri.path, {
            "Content-Type"  => "application/json",
            "Authorization" => "Bearer #{api_key}",
            #"OpenAI-Beta"   => "assistants=#{version}" # Removed OpenAI-Beta header
        })
        req.body = JSON.dump(request_body)

        response = http.request(req)
        begin
          raise "Error: #{response.code} #{response.message} #{response.body}" unless response.is_a?(Net::HTTPSuccess)
        rescue => e
          puts "Error communicating with Gemini API: #{e.message}".red
          return "Error communicating with Gemini API. Check your API key and network connection."
        end

        payload = JSON.parse(response.body)
        fc = payload.dig("choices", 0, "message", "function_call")

        if fc
            name = fc["name"]
            args = JSON.parse(fc["arguments"]) rescue {}
            result = callbacks[name.to_sym].call(args)

            # feed the function result back
            follow_up = {
                "model"    => model,
                "messages" => messages + [
                    { "role" => "function", "name" => name, "content" => JSON.dump(result) }
                ]
            }

            # Use the same headers hash as above – not req.to_hash
            fu_req = Net::HTTP::Post.new(uri.path, {
                "Content-Type"  => "application/json",
                "Authorization" => "Bearer #{api_key}",
                #"OpenAI-Beta"   => "assistants=#{version}" # Removed OpenAI-Beta header
            })
            fu_req.body = JSON.dump(follow_up)
            fu_res = http.request(fu_req)
            begin
              raise "Error after function call: #{fu_res.body}" unless fu_res.is_a?(Net::HTTPSuccess)
            rescue => e
              puts "Error communicating with Gemini API after function call: #{e.message}".red
              return "Error communicating with Gemini API after function call. Check your API key and network connection."
            end

            final = JSON.parse(fu_res.body).dig("choices",0,"message","content")
            messages << { "role" => "assistant", "content" => final }
            final
        else
            reply = payload.dig("choices",0,"message","content")
            messages << { "role" => "assistant", "content" => reply }
            reply
        end
    end # ask


    # manage copilot from terminal
    def console
        puts "Gemini-Copilot Console".blue
        puts "Type 'exit' to quit.".blue
        while true
            print "You: ".green
            prompt = gets.chomp
            break if prompt.downcase.strip == 'exit'
            begin
                puts "Gemini-Copilot: #{ask(prompt)}".blue
            rescue => e
                puts "Error: #{e.to_console}".red
            end
        end
    end # def console

end # class GeminiClient
