require_relative '../lib/openai-client.rb'
require_relative './config.rb'
require 'mass-client'

previous_messages = [
  { "role" => "user", "content" => "Your name is Thelma." },
  #{ "role" => "user", "content" => "Create a new tag named 'Urgent' with a red color code for account 123." },
  #{ "role" => "user", "content" => "What is your name?" }
  #{ "role" => "user", "content" => "How many tags do I have in my configuration?" }
]

$functions = [
  # tags
  {
    name: "count_tags",
    description: "Return the total number of tags in my configuration.",
  },
  {
    name: "list_tags",
    description: "List existing tags with optional filtering by name.",
    parameters: {
      type: "object",
      properties: {
        page: {
          type: "integer",
          description: "The page number to retrieve.",
        },
        limit: {
          type: "integer",
          description: "Number of tags per page.",
        },
        filters: {
          type: "object",
          properties: {
            name: {
              type: "string",
              description: "Filter tags by name using partial match.",
            },
          },
        },
      },
      required: ["page", "limit"],
    },
  },
  {
    name: "create_or_update_tag",
    description: "Create or update a tag with a given name and color code.",
    parameters: {
      type: "object",
      properties: {
        id_account: {
          type: "string",
          description: "The ID of the account.",
        },
        id_user: {
          type: "string",
          description: "The ID of the user.",
        },
        name: {
          type: "string",
          description: "The name of the tag.",
        },
        color_code: {
          type: "string",
          description: "The color code of the tag (e.g., 'red', 'green', 'blue').",
        },
      },
      required: ["id_account", "name", "color_code"],
    },
  },

  # leads
  {
    name: "count_leads",
    description: "Return the total number of leads.",
  },
  {
    name: "list_leads",
    description: "List existing leads with optional filtering by first_name, last_name, job_title.",
    parameters: {
      type: "object",
      properties: {
        page: {
          type: "integer",
          description: "The page number to retrieve.",
        },
        limit: {
          type: "integer",
          description: "Number of leads per page.",
        },
        filters: {
          type: "object",
          properties: {
            first_name: {
              type: "string",
              description: "Filter leads by first_name using partial match.",
            },
            last_name: {
              type: "string",
              description: "Filter leads by last_name using partial match.",
            },
            job_title: {
              type: "string",
              description: "Filter leads by job_title using partial match.",
            },
          },
        },
      },
      required: ["page", "limit"],
    },
  },
  {
    name: "add_tag_to_lead",
    description: "Add a tag to a lead. It is requred the ID of the lead and the name of the tag.",
    parameters: {
      type: "object",
      properties: {
        id_account: {
          type: "string",
          description: "The ID of the account.",
        },
        id_user: {
          type: "string",
          description: "The ID of the user.",
        },
        id: {
          type: "string",
          description: "The ID of the lead.",
        },
        name: {
          type: "string",
          description: "The name of the tag.",
        },
      },
      required: ["id_account", "id", "name"],
    },
  },
=begin
  {
    name: "lead_posts",
    description: "Get posts of a lead from his/her ID.",
    parameters: {
      type: "object",
      properties: {
        page: {
          type: "integer",
          description: "The page number to retrieve.",
        },
        limit: {
          type: "integer",
          description: "Number of posts per page.",
        },
        filters: {
          type: "object",
          properties: {
            id_lead: {
              type: "string",
              description: "The ID of the lead I want to get the posts from.",
            },
          },
        },
      },
      required: ["page", "limit", "id_lead"],
    },
  },
=end
]

$callbacks = {
  # Tags
  #
  :count_tags => lambda { |function_call_args|
    Mass::Tag.count
  },
  :list_tags => lambda { |function_call_args|
    # Extract arguments
    page = function_call_args["page"]
    limit = function_call_args["limit"]
    filters = function_call_args["filters"] || {}

    # Call mass-sdk method (hypothetical)
    result = Mass::Tag.page(page: page, limit: limit, filters: filters)

    # return
    return result.map { |o| o.desc }
  },
  :create_or_update_tag => lambda { |function_call_args|
    # Extract arguments
    id_account = function_call_args["id_account"]
    id_user = function_call_args["id_user"]
    name = function_call_args["name"]
    color_code = function_call_args["color_code"]

    # Call mass-sdk method (this is hypothetical, adjust according to mass-sdk's actual API)
    # For example:
    result = Mass::Tag.upsert(
      id_account: id_account,
      id_user: id_user,
      name: name,
      color_code: color_code
    )
    
    # return
    return result
  },

  # Leads
  #
  :count_leads => lambda { |function_call_args|
    Mass::Lead.count
  },
  :list_leads => lambda { |function_call_args|
    # Extract arguments
    page = function_call_args["page"]
    limit = function_call_args["limit"]
    filters = function_call_args["filters"] || {}

    # Call mass-sdk method (hypothetical)
    result = Mass::Lead.page(page: page, limit: limit, filters: filters)

    # return
    return result.map { |o| o.desc }
  },
  :add_tag_to_lead => lambda { |function_call_args|
    # Extract arguments
    id_account = function_call_args["id_account"]
    id_user = function_call_args["id_user"]
    id = function_call_args["id"]
    name = function_call_args["name"]

    # Call mass-sdk method (hypothetical)
    lead = Mass::Lead.get(id)

    # Add the tag to the lead
    lead.desc['tags'] = [] if lead.desc['tags'].nil?
    lead.desc['tags'] << name
    lead.desc['tags'].uniq!
    result = Mass::Lead.upsert(lead.desc)

    # return
    return result
  },
=begin
  :lead_posts => lambda { |function_call_args|
    # Extract arguments
    page = function_call_args["page"]
    limit = function_call_args["limit"]
    filters = function_call_args["filters"] || {}

    # Call mass-sdk method (hypothetical)
    result = Mass::Event.page(page: page, limit: limit, filters: filters)

    # return
    return result.map { |o| o.desc }
  },
=end
}

Mass.set(
    api_key: '4cf9cba7-77c8-483b-a2ee-06f164d524e6', #MASS_API_KEY,

    api_url: 'http://127.0.0.1', 
    api_port: 3000,
    api_version: '1.0',

    backtrace: true,
    subaccount: 'test1' #'my-agency'
)

$ai = OpenAIClient.new(
  api_key: OPENAI_API_KEY,
  model: MODEL,
  messages: previous_messages,
  functions: $functions,
  callbacks: $callbacks,
)

puts $ai.ask(
  "How many tags do I have in my configuration?"
)