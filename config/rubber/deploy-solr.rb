# installs, starts and stops solr
#
# * installation is ubuntu specific
# * start and stop tasks are using the thinking sphinx plugin

namespace :rubber do

  namespace :solr do

    rubber.allow_optional_tasks(self)

    after "rubber:install_packages", "rubber:solr:custom_install"

    desc "custom installing java and solr"
    task :custom_install, :roles => :solr do

      #upload rubber_env.jdk_path, "/tmp/#{rubber_env.jdk}"
      upload rubber_env.solr_xml_path, "/tmp/#{rubber_env.solr_xml}"
      upload rubber_env.tarz_config_files, "/tmp/solr_conf.tar.gz"
      rubber.sudo_script 'install_java_solr', <<-ENDSCRIPT
          root@li556-160:~# add-apt-repository -y ppa:webops/solr-3.5
          apt-get update
          apt-get install solr-tomcat
          root@solr01:/mnt/so_berlin-production/current/solr/conf# cp solrconfig.xml /usr/share/solr/conf/
          root@solr01:/mnt/so_berlin-production/current/solr/conf# cp schema.xml /usr/share/solr/conf/

      ENDSCRIPT
    end

    desc "start solr"
    task :start_solr, :roles => :solr  do
      rubber.sudo_script 'start_solr', <<-ENDSCRIPT
        echo 'starting tomcat'
        nohup service tomcat6 start  &
        sleep 5
      ENDSCRIPT
    end

    desc "stop solr"
    task :stop_solr, :roles => :solr do
      rubber.sudo_script 'stop_solr', <<-ENDSCRIPT
        echo 'stoping tomcat'
        service tomcat6 stop
      ENDSCRIPT
    end
  end

end
