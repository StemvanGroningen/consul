class Widget::Feeds::ProcessComponent < ApplicationComponent; end

require_dependency Rails.root.join("app", "components", "widget", "feeds", "process_component").to_s
