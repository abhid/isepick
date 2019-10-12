require "isepick/version"
require "faraday"
require "nokogiri"

module Isepick
  class IseMNT
    def initialize(mnt_host, mnt_user, mnt_password)
      @client = Faraday.new("https://#{mnt_host}/admin/API/mnt/") do |conn|
        conn.basic_auth(mnt_user, mnt_password)
        conn.adapter Faraday.default_adapter
        conn.ssl[:verify] = false
        conn.headers["Accept"] = "application/xml"
      end
    end

    def get_all_endpoints(params*)
      JSON.parse($ise_psn.get("endpoint", {pageSize: params[:pageSize], page: params[:page]}).body)["SearchResult"]
      return endpoints_json["resources"]
    end
  end

  class IseERS
    def initialize(psn_host, psn_user, psn_password)
      @client = Faraday.new("https://#{psn_host}:9060/ers/config/") do |conn|
        conn.basic_auth(psn_user, psn_password)
        conn.adapter Faraday.default_adapter
        conn.ssl[:verify] = false
        conn.headers["Accept"] = "application/json"
      end
    end
  end
end
