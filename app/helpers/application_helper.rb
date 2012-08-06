module ApplicationHelper

  def sortable(column, title = nil)
    title ||= column.titleize
    direction = column == params[:sort] && params[:direction] == "asc" ? "desc" : "asc"
    link_to title, :sort => column, :direction => direction
  end

  def full_title(page_title)

    base_title = "paperPiazza"

    if page_title.empty?
      base_title
    else
      "#{base_title} | #{page_title}"
    end

  end

  def https
    if Rails.env.development?
      "http"
    else
      "https"
    end
  end

  def my_sanitize(text)
    tags = ["a", "address", "em", "strong", "b", "i", "big", "small", "sub", "sup", "cite", "code", "img", "ul", "ol", "li", "dl", "lh", "dt", "dd", "br", "p", "table", "th", "td", "tr", "pre", "blockquote", "nowiki", "h1", "h2", "h3", "h4", "h5", "h6", "hr"]
    sanitize(text, :tags => tags)
  end

  def safe_raw(text)
    raw(my_sanitize(text))
  end

  def login_link
    if current_user
      link_to raw("<i class='icon-signout'></i> Logout"), logout_path
    else
      link_to "Login", login_path
    end
  end

  def collapse_button(target)
    content_tag :a, :class => ["btn", "btn-navbar"] , "data-toggle" => :collapse, "data-target" => target do
      content_tag(:span, "", :class => "icon-bar") + content_tag(:span, "", :class => "icon-bar") + content_tag(:span, "", :class => "icon-bar")
    end
  end

  def dropdown_link(text, target_id)
    link_to raw("#{h(text)} <b class='caret'></b>"), target_id, :class => "dropdown-toggle", :"data-toggle" => "dropdown"
  end

  def pluralize_word(count, word)
    count == 1 ? word : word.pluralize
  end

  def check_box_array_tag(name, value = "1", checked = false, options = {})
    html_options = { "type" => "checkbox", "name" => name, "id" => sanitize_to_id(name) + value.to_s, "value" => value }.update(options.stringify_keys)
    html_options["checked"] = "checked" if checked
    tag :input, html_options
  end

  def bootstrap_icon(icon)
    return "<i class=\"icon-#{icon}\"></i>".html_safe
  end
end
