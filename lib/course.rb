class Course < ActiveRecord::Base
  has_many :sections

  def update
    require 'open-uri'
    error_message = "I'm sorry. At the moment, there are no courses that correspond to your search criteria."

    return if !self.title.nil?
    
    url = "http://www.college.columbia.edu/unify/getApi/bulletinSearch.php?courseIdentifierVar=" + course_key
    doc = nil
    school = nil
    [ 'CC', 'EN', 'BC', 'GSAS', 'CE', 'SIPA', 'GS' ].each do |s|
      begin
        doc = Nokogiri::HTML(open( url + '&school=' + s ))
        unless doc.to_html.match( error_message )
          school = s
          break
        end
      rescue
        next
      end
    end

    # give up if no html file found for course
    return if doc.to_html.match( error_message ) or doc.nil?

    brief = ""
    if school == 'CC'or school == 'GSAS'
      doc.css( "div.course-description > p" ).each do |p|
        if p.to_html.gsub( "\n", "" ).match( /<strong>.*<\/strong>/ )
          brief = p.to_html.gsub( "\n", "" ).gsub(/<em>Not offered in [0-9]+-[0-9]+.<\/em>/, "").gsub( /\s+/, " " ).gsub( /&amp;/, "&" ).strip
          break
        end
      end
    else
      brief = doc.css( "div.course-description" ).first.to_html.gsub( "\n", "" )
    end

    # title
    match = brief.gsub( /<\/?strong>/, '#' ).match( /#([^#]+)/ )

    self.title = match[1].gsub( /<\/?[^>]*>/, " " ).gsub( /([A-Z]{2,4}\s+)?[A-Z]\s?[0-9]+([xy]+)?(\sand\sy|\sor\sy)?-?(\s*\*\s*)?\.?/, "" ).gsub( /\s+/, " " ).strip
    self.title.gsub!( /\s*\(\s*(S|s)ection\s*[0-9]+\s*\)\s*/, '' )
    self.title.gsub!( /\..*/, '' )
    
    # description
    match = brief.match( /<\/strong>\s*(<em>\s*[0-9.]+\s*pts\.[^<]*<\/em>)?\s*(.*)$/ )
    self.description = match[2].gsub(/<\/?[^>]*>/, " ").gsub( /\s+/, " " ).strip

    # points
    match = brief.match( /([0-9.]+)\s*pts\./ )
    match = brief.match( /([0-9.]+)\s*points/ ) if match.nil? 

    self.points = match[1].gsub(/<\/?[^>]*>/, " ").gsub( /\s+/, " " ).strip unless match.nil?

    self.updated_at = Time.now
    self.save!
  end
end
