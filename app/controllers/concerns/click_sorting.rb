module ClickSorting
  extend ActiveSupport::Concern

  def click_sort_info(columns, default_sort, redirect_url)
    sort = cookies["#{controller_name}_#{action_name}_sort"]
    sort = default_sort if sort.blank?
    dir = sort.slice(0)
    if params[:sort].present?
      s = params[:sort]
      if columns.map{|c| c[:key]}.include?(s)
        if sort.ends_with?(s)
          # toggling order
          dir = (dir == '+' ? '-' : '+')
        else
          dir = '+'
        end
        cookies["#{controller_name}_#{action_name}_sort"] = "#{dir}#{s}"
        # we redirect here so we dont keep carrying over the sort param?  otherwise how could we toggle asc/desc
        redirect_to redirect_url
        return
      end
    end

    sort = sort[1..-1]
    columns.each do |column|
      if column[:key] == sort
        column[:sort] = dir
        break
      end
    end
    sort = sort.split(",").map{|e| "#{e} #{dir == '+' ? ' asc' : ' desc'}"}.join(", ")

    # append the default sort info to make the sorting more stable, intuitive
    # TODO make smarter so column only exists in sort criteria once
    def_dir = default_sort.slice(0)
    def_sort = default_sort[1..-1]
    def_sort = def_sort.split(",").map{|e| "#{e} #{def_dir == '+' ? ' asc' : ' desc'}"}.join(", ")
    sort = sort + ',' + def_sort if sort.present? and def_sort.present? and sort != def_sort
    sort
  end
end