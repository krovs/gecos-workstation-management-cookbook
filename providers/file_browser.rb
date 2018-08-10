#
# Cookbook Name:: gecos-ws-mgmt
# Provider:: file_browser
#
# Copyright 2013, Junta de Andalucia
# http://www.juntadeandalucia.es/
#
# All rights reserved - EUPL License V 1.1
# http://www.osor.eu/eupl
#

action :setup do
  begin
# OS identification moved to recipes/default.rb
#    os = `lsb_release -d`.split(":")[1].chomp().lstrip()
#    if new_resource.support_os.include?(os)
    if new_resource.support_os.include?($gecos_os)
      users = new_resource.users
      users.each_key do |user_key|
        nameuser = user_key 
        username = nameuser.gsub('###','.')
        user = users[user_key]

        #default_folder_viewer
        if !user.default_folder_viewer.empty? and !user.default_folder_viewer.nil?
          desktop_gsettings "default-folder-viewer" do
            schema "org.nemo.preferences"
            key "default-folder-viewer"
            user username
            value user.default_folder_viewer
            action :nothing
          end.run_action(:set)
        end

        #show_hidden_files
        if !user.show_hidden_files.empty? and !user.show_hidden_files.nil? 
          desktop_gsettings "show-hidden-files" do
            schema "org.nemo.preferences"
            key "show-hidden-files"
            user username
            value user.show_hidden_files
            action :nothing
          end.run_action(:set)
        end
     
        #show_search_icon_toolbar
        if !user.show_search_icon_toolbar.empty? and !user.show_search_icon_toolbar.nil? 
          desktop_gsettings "show-search-icon-toolbar" do
            schema "org.nemo.preferences"
            key "show-search-icon-toolbar"
            user username
            value user.show_search_icon_toolbar
            action :nothing
          end.run_action(:set)
        end

        #click_policy
        if !user.click_policy.empty? and !user.click_policy.nil? 
          desktop_gsettings "click-policy" do
            schema "org.nemo.preferences"
            key "click-policy"
            user username
            value user.click_policy
            action :nothing
          end.run_action(:set)
        end

        #confirm_trash
        if !user.confirm_trash.empty? and !user.confirm_trash.nil? 
          desktop_gsettings "confirm-trash" do
            schema "org.nemo.preferences"
            key "confirm-trash"
            user username
            value user.confirm_trash
            action :nothing
          end.run_action(:set)
        end


      end
    else
      Chef::Log.info("This resource is not support into your OS")
    end

    # save current job ids (new_resource.job_ids) as "ok"
    job_ids = new_resource.job_ids
    job_ids.each do |jid|
      node.normal['job_status'][jid]['status'] = 0
    end

  rescue Exception => e
    # just save current job ids as "failed"
    # save_failed_job_ids
    Chef::Log.error(e.message)
    job_ids = new_resource.job_ids
    job_ids.each do |jid|
      node.normal['job_status'][jid]['status'] = 1
      if not e.message.frozen?
        node.normal['job_status'][jid]['message'] = e.message.force_encoding("utf-8")
      else
        node.normal['job_status'][jid]['message'] = e.message
      end
    end
  ensure
    
    gecos_ws_mgmt_jobids "file_browser_res" do
       recipe "users_mgmt"
    end.run_action(:reset) 
    
  end
end
