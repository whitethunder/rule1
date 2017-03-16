#!/home/mwhite/.rbenv/shims/ruby
require 'date'

FILE_THRESHOLD = 1_500

def import_data(current, option_chains_open)
  date = current.strftime("%Y-%m-%d")
  enter_date(date)
  toggle_option_chains
  toggle_option_chains if option_chains_open
  export_file(date)
  sleep
end

def enter_symbol(symbol)
  mouse_move(480, 165)
  left_click
  press_key("BackSpace", 5)
  enter_string(symbol)
  sleep(3)
end

def toggle_option_chains
  mouse_move(2515, 275)
  left_click
  sleep
end

def enter_date(date)
  mouse_move(2430, 156)
  left_click
  sleep
  press_key("ctrl+a")
  date = Date.parse(date)
  date = date.strftime("%m/%d/%Y")
  slow_enter_string(date)
  sleep
end

def export_file(date)
  open_export_menu
  click_export
  input_filename(date)
  save_file
end

def open_export_menu
  mouse_move(2530, 115)
  left_click
  sleep
end

def click_export
  mouse_move(2500, 400)
  left_click
  sleep
end

def input_filename(date)
  sleep(2)
  press_key("ctrl+a")
  sleep(0.5)
  enter_string(path(date))
  sleep
end

def path(date)
  "/home/mwhite/Downloads/Rule1/TOSData/raw_data/RUTOptions-#{date}.csv"
end

def save_file
  mouse_move(1760, 1130)
  left_click
  sleep
end

def enter_string(string)
  string = format_string(string)
  press_key(string)
  press_key("Return")
  sleep
end

def slow_enter_string(string)
  string = format_string(string)
  split = string.split(" ")
  split.each do |char|
    press_key(char)
    sleep(0.1)
  end
  sleep(0.5)
  press_key("Return")
  sleep
end

def format_string(string)
  string = string.split("").join(" ")
  string.gsub!("/", "slash")
  string.gsub!("-", "minus")
  string.gsub!(".", "period")
  string.gsub!("_", "underscore")
  string
end

def mouse_move(x, y)
  `#{executable} mousemove #{x} #{y}`
end

def left_click
  `#{executable} click 1`
end

def double_click
  `#{executable} click 1 --repeat 2`
end

def press_key(key, times=1)
  keys = "#{key} " * times
  `#{executable} key #{keys}`
end

def weekday?(date)
  (1..5).cover?(date.wday)
end

def sleep(time=1)
  `sleep #{time}`
end

def blank?(obj)
  obj.nil? || obj.empty?
end

def file_size_correct?(date)
  File.size(path(date)) > FILE_THRESHOLD
end

def executable
  "xdotool"
end

symbol = ARGV[0]
start_date = ARGV[1]
raise "No symbol entered" if blank?(symbol)
raise "No start date entered" if blank?(start_date)
puts "Importing #{symbol} options from #{start_date} to #{Date.today.strftime('%Y-%m-%d')}"
option_chains_open = true
current = Date.parse(start_date)
tries = 0
# enter_symbol(symbol)
until current > Date.today
  if weekday?(current)
    import_data(current, option_chains_open)
    if file_size_correct?(current.strftime("%Y-%m-%d")) || tries > 3
      current += 1
      tries = 0
      option_chains_open = true
    else
      File.unlink(path(current.strftime("%Y-%m-%d")))
      option_chains_open = false
      tries += 1
    end
  else
    current += 1
    tries = 0
  end
end

#TODO: Remove market holidays
