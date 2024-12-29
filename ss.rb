#!/usr/bin/ruby

require 'optparse'
require 'selenium-webdriver'
require 'fileutils'
require 'mini_magick'

browser_toolbar_height = 162
ss_path = "/tmp/ss.png"

options = {
  :width  => 1000,
  :height => 840,
}

OptionParser.new { |opt|
  opt.on('-w WIDTH', '--width WIDTH', 'viewport width') { |v| options[:width] = v }
  opt.on('-h HEIGHT', '--height HEIGHT', 'viewport height') { |v| options[:height] = v }
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

#Selenium::WebDriver.logger.level = :debug

service = Selenium::WebDriver::Service.firefox
service.executable_path = "/usr/local/bin/geckodriver"

opts = Selenium::WebDriver::Options.firefox
opts.args = ["--headless"]

begin
  driver = Selenium::WebDriver.for(:firefox, options: opts, service: service)
  driver.manage.timeouts.implicit_wait = 5
  wait = Selenium::WebDriver::Wait.new(:timeout => 5)

  driver.manage.window.resize_to(options[:width].to_i, options[:height].to_i + browser_toolbar_height)
  driver.navigate.to @url

  if options[:selector]
    wait.until { driver.find_element(:css, options[:selector]).displayed? }
  elsif options[:xpath]
    wait.until { driver.find_element(:xpath, options[:xpath]).displayed? }
  else
    sleep 3
  end

  sleep 2

  driver.save_screenshot(ss_path)
  puts "Screenshot: #{ss_path} is saved"
ensure
  driver.quit
end
