require "multi_json"

module Rulers
  module Model
    class FileModel
      def initialize(filename)
        @filename = filename
        basename = File.split(filename)[-1]
        @id = File.basename(basename, ".json").to_i
        obj = File.read(filename)
        @hash = MultiJson.load(obj)
      end

      def [](name)
        @hash[name.to_s]
      end

      def []=(name, value)
        @hash[name] = value
      end

      def update(attrs)
        attrs.each do |key, val|
          self[key] = val
        end
        save
      end

      def save
        File.open("db/quotes/#{@id}.json", "w") do |f|
          f.write MultiJson.dump(@hash)
        end
        self
      end

      class << self
        def find(id)
          begin 
            FileModel.new("db/quotes/#{id}.json")
          rescue
            return nil
          end
        end

        def all
          files = Dir["db/quotes/*.json"]
          files.map{ |f| FileModel.new(f) }
        end

        def create(attrs)
          hash = {}
          hash["submitter"] = attrs["submitter"] || ""
          hash["quote"] = attrs["quote"] || ""
          hash["attribution"] = attrs["attribution"] || ""

          files = Dir["db/quotes/*.json"]
          names = files.map{ |f| File.split(f)[-1] }
          highest = names.map{ |b| b.to_i }.max
          id = highest + 1
          File.open("db/quotes/#{id}.json", "w") do |f|
            f.write <<-TEMPLATE
            {
              "submitter": "#{hash["submitter"]}",
              "quote": "#{hash["quote"]}",
              "attribution": "#{hash["attribution"]}"
            }
            TEMPLATE
          end
          FileModel.new("db/quotes/#{id}.json")
        end

        def method_missing(name, *args, &block)
          name = name.to_s
          if name =~ /^find_all_by_(.+)/
            res = []
            quotes = all
            quotes.each do |q|
              res << q if q[$1] == args[0]
            end
            return res
          else
            super
          end
        end
      end
    end
  end
end