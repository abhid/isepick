require "isepick/version"
require "faraday"
require "nokogiri"
require "json"
require 'active_support/core_ext/hash'

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

    def activeSessions(pageSize = 25, page = 1)
      session_xml = Nokogiri::XML(@client.get("Session/ActiveList", {pageSize: pageSize, page: page}).body)
      return Hash.from_xml(session_xml.to_s)
    end

    def session_filterByMAC(mac_addr)
      filter_param = mac_addr.gsub(/[^a-fA-F0-9]/, "").upcase.gsub(/(.{2})(?=.)/, '\1:\2')
      session_xml = Nokogiri::XML(@client.get("Session/MACAddress/#{filter_param}").body)
      return Hash.from_xml(session_xml.to_s)
    end

    def session_filterByIP(ip_addr)
      session_xml = Nokogiri::XML(@client.get("Session/EndPointIPAddress/#{ip_addr}").body)
      return Hash.from_xml(session_xml.to_s)
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
    # Endpoints
    def ep_getAll(pageSize = 25, page = 1)
      return JSON.parse(@client.get("endpoint").body)
    end

    def ep_get(ep_id)
      return JSON.parse(@client.get("endpoint/#{ep_id}").body)
    end

    def ep_filterByMAC(mac_addr)
      filter_param = mac_addr.gsub(/[^a-fA-F0-9]/, "").upcase.gsub(/(.{2})(?=.)/, '\1:\2')
      return JSON.parse(@client.get("endpoint?filter=mac.EQ.#{filter_param}").body)
    end

    # Network Device Group
    def ndg_getAll()
      current_page = 1
      output = []

      loop do
        cur_output = JSON.parse(@client.get("networkdevicegroup?size=25&page=#{current_page}").body)
        output += cur_output["SearchResult"]["resources"]
        if cur_output["SearchResult"].key?("nextPage")
          current_page += 1
        else
          break
        end
      end
      return output
    end

    def ndg_get(ndg_id)
      return JSON.parse(@client.get("networkdevicegroup/#{ndg_id}").body)
    end

    # Network Device
    def nd_getAll()
      current_page = 1
      output = []

      loop do
        cur_output = JSON.parse(@client.get("networkdevice?size=25&page=#{current_page}").body)
        output += cur_output["SearchResult"]["resources"]
        if cur_output["SearchResult"].key?("nextPage")
          current_page += 1
        else
          break
        end
      end
      return output
    end

    def nd_get(nd_id)
      return JSON.parse(@client.get("networkdevice/#{nd_id}").body)
    end

    # Endpoint Identity Group
    def eig_getAll()
      current_page = 1
      output = []

      loop do
        cur_output = JSON.parse(@client.get("endpointgroup?size=25&page=#{current_page}").body)
        output += cur_output["SearchResult"]["resources"]
        if cur_output["SearchResult"].key?("nextPage")
          current_page += 1
        else
          break
        end
      end
      return output
    end

    def eig_get(eig_id)
      return JSON.parse(@client.get("endpointgroup/#{eig_id}").body)
    end

    def eig_getEndpoints(eig_id)
      current_page = 1
      output = []

      loop do
        cur_output = JSON.parse(@client.get("endpoint?size=25&page=#{current_page}&filter=groupId.EQ.#{eig_id}").body)
        output += cur_output["SearchResult"]["resources"]
        if cur_output["SearchResult"].key?("nextPage")
          current_page += 1
        else
          break
        end
      end
      return output
    end

    # Downloadable ACL
    def dacl_getAll()
      current_page = 1
      output = []

      loop do
        cur_output = JSON.parse(@client.get("downloadableacl?size=25&page=#{current_page}").body)
        output += cur_output["SearchResult"]["resources"]
        if cur_output["SearchResult"].key?("nextPage")
          current_page += 1
        else
          break
        end
      end
      return output
    end

    def dacl_get(uuid)
      return JSON.parse(@client.get("downloadableacl/#{uuid}").body)
    end

    # Authorization Profile
    def aznprofile_getAll()
      current_page = 1
      output = []

      loop do
        cur_output = JSON.parse(@client.get("authorizationprofile?size=25&page=#{current_page}").body)
        output += cur_output["SearchResult"]["resources"]
        if cur_output["SearchResult"].key?("nextPage")
          current_page += 1
        else
          break
        end
      end
      return output
    end

    def aznprofile_get(uuid)
      return JSON.parse(@client.get("authorizationprofile/#{uuid}").body)
    end
  end
end
