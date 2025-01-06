require_relative '../lib/simple-openai-client.rb'
require_relative './config.rb'

previous_messages = [
  { "role" => "system", "content" => "Your name is Thelma." },
  #{ "role" => "user", "content" => "Create a new tag named 'Urgent' with a red color code for account 123." },
  #{ "role" => "user", "content" => "What is your name?" }
  #{ "role" => "user", "content" => "How many tags do I have in my configuration?" }
]

$ai = OpenAIClient.new(
  api_key: OPENAI_API_KEY,
  model: MODEL,
  messages: previous_messages
)

puts $ai.ask(
  "What is your name?"
)