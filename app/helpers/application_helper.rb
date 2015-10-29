module ApplicationHelper
  def repo_name url
    return url[(url.rindex("/") + 1)..-1] if url.include? "/"
  end

  def breadcrumbs(group, user = nil)
    output = group.ancestors([]).sort{|a,b| a.path <=> b.path}.to_a
    output.push(group)
    output.map!{|g| (link_to g.title, group_path(g), class: "breadcrumb")}
    if user
      output.push((link_to user.username, user_path(user), class: "breadcrumb"))
    end
    output = output.join("_")
    if user
      output += ("<a>admin</a>") if group.has_admin?(user)
      if user == current_user
        output += (link_to "squad", group_membership_path(group, user), class: (group.has_priority?(user) ? "yes" : "no"), method: :put)
      else
        output += ("<a>squad</a>")
      end
    end
    return output.html_safe
  end

  def membership_list(memberships)
    output = ""
    memberships.sort{|a, b| a.group.path <=> b.group.path}.each do |m|
      group = m.group
      isadmin = m.is_admin ? " (admin)" : ""
      linktext = group.path + isadmin
      output += "<li>" + (link_to linktext, group_path(group)) + "</li>"
    end
    return output.html_safe
  end

  def group_list(groups)
    output = ""
    groups.sort{|a, b| a.path <=> b.path}.each do |group|
      output += "<li>#{link_to group.path, group_path(group)}</li>"
    end
    return output.html_safe
  end

  def group_descendant_list(group)
    output = ""
    group.descendants.each do |subgroup|
      output += "<li>" + link_to(subgroup.path, group_path(subgroup)) + "</li>"
    end
    return output.html_safe
  end

  def group_descendant_tree(group)
    output = "<li><a href='/groups/#{group.id}'>#{group.title}</a><ul>"
    group.children.each do |child|
      output += group_descendant_tree(child)
    end
    output += "</ul></li>"
    return output.html_safe
  end

  def avatar user
    if user.image_url
      return link_to image_tag(user.image_url), user_path(user), class: :avatar
    end
  end

  def average_status collection
    if collection.count > 0
     return (collection.inject(0){|sum, i| sum + (i.status || 0)}.to_f / collection.count).round(2)
   else
     return 0
   end
  end

  def color_of input
    return if !input
    if !(input.class < Numeric)
      input = average_status(input)
    end
    case input * 100
    when 0...50
      return "s0"
    when 50...100
      return "s1"
    when 100...150
      return "s2"
    when 150..200
      return "s3"
    end
  end

  def color_of_percent input
    case input
    when 0...25
      return "s0"
    when 25...50
      return "s1"
    when 50...75
      return "s2"
    when 75..100
      return "s3"
    end
  end

  def color_of_status input
    case input * 100
    when 0...50
      return "s0"
    when 50...100
      return "s1"
    when 100...150
      return "s2"
    when 150..200
      return "s3"
    end
  end

  def percent_of collection, value
    divisor = collection.select{|i| i.status == value}
    divisor = divisor.length
    if divisor <= 0
      percent = 0
    else
      percent = (divisor.to_f / collection.length).round(2)
    end
    return (percent * 100).to_i
  end

  def markdown(text)
    options = {
      filter_html:     true,
      hard_wrap:       true,
      link_attributes: { rel: 'nofollow', target: "_blank" },
      space_after_headers: true,
      fenced_code_blocks: true
    }

    extensions = {
      autolink:           true,
      superscript:        true,
      disable_indented_code_blocks: true,
      fenced_code_blocks: true
    }
    if text.blank?
      nil
    else
      renderer = Redcarpet::Render::HTML.new(options)
      markdown = Redcarpet::Markdown.new(renderer, extensions)
      markdown.render(text).html_safe
    end
  end

  def is_admin_of_anything? user
    return (user.memberships.select{|m| m.is_admin?}.count > 0)
  end

  def status_buttons record
    output = ""
    record.class.statuses.each do |i, status|
      id = "a#{record.id}_#{i}"
      checked = "checked" if record.status == i
      output += "<td><input type='radio' name='a#{record.id}' id='#{id}' value='#{i}' #{checked} data-record-url='#{url_for record}' />"
      output += "<label for='#{id}'>#{status}</label></td>"
    end
    return output.html_safe
  end

end
