#
# Configuring tire is easy -- just copy the URL from the bonsai service into the
# env var that tire expects
#
ENV['ELASTICSEARCH_URL'] = ENV['BONSAI_URL'] if ENV['BONSAI_URL']

#
# Mongoid config is contained in mongoid.yml. We just load it here
#
Mongoid.load!(File.join(File.dirname(__FILE__), 'mongoid.yml'))
