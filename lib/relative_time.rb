class Time
  def self.relative_time(start_time)
    diff_seconds = Time.now.to_i - start_time.to_i
    case diff_seconds
      when 0 .. 59
        "#{diff_seconds}s"
      when 60 .. (3600-1)
        "#{diff_seconds/60}m"
      when 3600 .. (3600*24-1)
        "#{diff_seconds/3600}h"
      when (3600*24) .. (3600*24*30-1)
        "#{diff_seconds/(3600*24)}d"
      when (3600*24*30)..(3600*24*30*4-1)
        "#{diff_seconds/(3600*24)}w"
      else
        start_time.strftime("%m/%d/%Y")
    end
  end
end
