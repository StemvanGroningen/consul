class AdminLegislationSanitizer < WYSIWYGSanitizer
  def allowed_tags
    super + %w[img h1 h2 h3 h4 h5 h6 hr blockquote code p ul ol li strong em u s a table thead tbody tr th td]
  end

  def allowed_attributes
    super + %w[alt src id href target style]
  end
end
