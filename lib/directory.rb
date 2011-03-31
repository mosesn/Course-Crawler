class Directory
  
  def self.crawl
    require 'open-uri'
        
    # Crawl sections
    #subjects = Subject.order( "id" )
    subjects = []
    num_subjects = subjects.size
    start_time = Time.now
    sections_crawled = 0

    subjects.each_with_index do |s, index|
      unless s.abbreviation.nil?
        url = "http://www.columbia.edu/cu/bulletin/uwb/subj/" + s.abbreviation
        begin
          doc = Nokogiri::HTML(open(url))
        rescue
          puts "Bad subject URL: #{url}"
          next
        end

        section_urls = doc.css('a')
        sections_per_minute = (sections_crawled*60/(Time.now-start_time)).round(1)
        sections_crawled = sections_crawled + section_urls.length
        
        puts "(" << (index+1).to_s << " of " << num_subjects.to_s << "): " << url << " (" << section_urls.length.to_s << " sections; " << sections_per_minute.to_s << " sections/min)"
        section_urls.each { |a| Section.update_or_create( url + "/" + a.content ) if a.content =~ /[A-Z0-9]+-[0-9]+-[0-9]+/ }
      end
    end
    
    # Crawl courses
    Course.all.each_with_index do |c, index|
      puts "(#{index+1} of #{courses.size}) Crawling #{c.course_key}"
      c.update
    end

  end
end
