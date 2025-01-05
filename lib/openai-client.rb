# Reference:
# - https://platform.openai.com/docs/guides/function-calling/supported-models
#

require 'net/http'
require 'uri'
require 'json'

class OpenAIClient
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
      uri = URI("https://api.openai.com/v1/models")
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
    # Return the response.
    def ask(s, context: [])
        # Use v1 chat completions endpoint (with functions support)
        uri = URI("https://api.openai.com/v1/chat/completions")

        # add contenxt to the history of messages
        self.messages += context

        # add new question asked by the user to the history of messages
        self.messages << { "role" => "user", "content" => s }

        request_body = {
            "model" => self.model, # A known model that supports function calling; update as needed
            "messages" => self.messages
            # To let the model decide if and when to call a function, omit "function_call"
            # If you want the model to call a function explicitly, you can add: "function_call" => "auto"
        }

        request_body["functions"] = self.functions if self.functions.size > 0

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true

        request = Net::HTTP::Post.new(uri.path, {
            "Content-Type" => "application/json",
            "Authorization" => "Bearer #{self.api_key}",
            "OpenAI-Beta" => "assistants=#{version}"
        })
        request.body = JSON.dump(request_body)

        response = http.request(request)

        if response.is_a?(Net::HTTPSuccess)
            response_json = JSON.parse(response.body)

            # Check if the assistant decided to call a function
            function_call = response_json.dig("choices", 0, "message", "function_call")

            unless function_call
                # add new response from AI to the history of messages
                assistant_reply = response_json.dig("choices", 0, "message", "content")
                self.messages << { "role" => "assistant", "content" => assistant_reply }
                # return the resonse from AI
                return assistant_reply
            else
                function_call_name = function_call["name"]
                function_call_args = JSON.parse(function_call["arguments"]) rescue {}
                
                # Handle the function call
                result = self.callbacks[function_call_name.to_sym].call(function_call_args);

                # Now we send the function result back to the assistant as another message:
                follow_up_uri = URI("https://api.openai.com/v1/chat/completions")
                follow_up_messages = messages.dup
                follow_up_messages << {
                    "role" => "function",
                    "name" => function_call_name,
                    "content" => JSON.dump(result)
                }

                follow_up_request_body = {
                    "model" => self.model,
                    "messages" => follow_up_messages
                }

                follow_up_http = Net::HTTP.new(follow_up_uri.host, follow_up_uri.port)
                follow_up_http.use_ssl = true

                follow_up_request = Net::HTTP::Post.new(follow_up_uri.path, {
                    "Content-Type" => "application/json",
                    "Authorization" => "Bearer #{OPENAI_API_KEY}",
                    "OpenAI-Beta" => "assistants=#{version}"
                })
                follow_up_request.body = JSON.dump(follow_up_request_body)
                
                follow_up_response = follow_up_http.request(follow_up_request)
                if follow_up_response.is_a?(Net::HTTPSuccess)
                    follow_up_response_json = JSON.parse(follow_up_response.body)
                    final_reply = follow_up_response_json.dig("choices", 0, "message", "content")
                    # add new response from AI to the history of messages
                    self.messages << { "role" => "assistant", "content" => final_reply }
                    # return the response form the AI.
                    return final_reply
                else
                    raise "Error after function call: #{follow_up_response.code} - #{follow_up_response.message} - #{follow_up_response.body}"
                end
            end
        else
            raise "Error: #{response.code} - #{response.message} - #{response.body}"
        end
    end # def ask

    # manage copilot from terminal
    def console
        puts "Mass-Copilot Console".blue
        puts "Type 'exit' to quit.".blue
        while true
            print "You: ".green
            prompt = gets.chomp
            break if prompt.downcase.strip == 'exit'
            begin
                puts "Mass-Copilot: #{ask(prompt)}".blue
            rescue => e
                puts "Error: #{e.to_console}".red
            end
        end
    end # def console

end # class OpenAIClient
  