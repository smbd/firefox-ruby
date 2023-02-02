#!/usr/bin/ruby

require 'optparse'
require 'selenium-webdriver'
require 'fileutils'
require 'mini_magick'

require 'pp'

options = {
  :width  => "1000",
  :height => "1000",
}

OptionParser.new { |opt|
  opt.on('-w WIDTH', '--width WIDTH', 'browser width') { |v| options[:width] = v }
  opt.on('-h HEIGHT', '--height HEIGHT', 'browser height') { |v| options[:height] = v }
  opt.on('-s SELECTOR', '--selector SELECTOR', 'CSS selector of element that should be displayed') { |v| options[:selector] }
  opt.on('-x XPATH', '--xpath XPATH', 'XPath of element that should be displayed') { |v| options[:selector] }
  
  opt.parse!(ARGV)
}

if options[:selector] and options[:xpath]
  puts "both CSS Selector and XPath are specified, use only one"
  exit 1
end

if ARGV.size > 0
  @url = ARGV[0]
else
  puts "Usage: #{$0} [-w WIDTH] [-h HEIGHT] [-s SELECTOR] [-x XPATH] URL"
  exit 1
end


selenium_opts = Selenium::WebDriver::Firefox::Options.new
selenium_opts.args = ["--headless", "--height=#{options[:height]}", "--width=#{options[:width]}" ]
selenium_opts.profile = Selenium::WebDriver::Firefox::Profile.from_name "default-release"

driver = Selenium::WebDriver.for(:firefox, capabilities: selenium_opts)
driver.navigate.to @url

wait = Selenium::WebDriver::Wait.new(:timeout => 10)

if options[:selector]
  wait.until { driver.find_element(:css, options[:selector]).displayed? }
elsif options[:xpath]
  wait.until { driver.find_element(:xpath, options[:xpath]).displayed? }
else
  sleep 3
end

sleep 10

year  = Time.now.strftime('%Y')
month = Time.now.strftime('%m')
date  = Time.now.strftime('%d')
time  = Time.now.strftime('%H%M')

ss_dir = "/save/#{year}/#{month}/#{date}"
FileUtils.mkdir_p(ss_dir)

ss_basename="ss_#{time}"

driver.save_screenshot("#{ss_dir}/ss.png")
driver.quit

img = MiniMagick::Image.open("#{ss_dir}/ss.png")
img.format('webp')
img.quality(70)
img.write("#{ss_dir}/#{ss_basename}.webp")

File.delete("/#{ss_dir}/ss.png")
