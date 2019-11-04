# frozen_string_literal: true

class Crawler::DriftingRuby < CrawlerBase
  ROOT = "https://www.driftingruby.com".freeze
  SIGN_IN = "#{ROOT}/users/sign_in".freeze

  private

  def run_crawler
    (from..to).each{|index| scan_page(index)}
  end

  def scan_page(index)
    doc = Nokogiri::HTML(open(episode_url(index)))
    episodes = doc.css('.episode_card')
    episodes.each do |episode|
      episode.css('.card-body').each do |card_body|
        href = card_body.css('.episode_title a')[0]['href']
        title = card_body.css('.episode_title a').text
        number = card_body.css('.episode_light').text
        date = card_body.css('.text-muted').text
        label = card_body.css('.label').text
        description = card_body.css('p.mt-3').text

        save_episode!(href, title, number, date, label, description)
      end
    end
  end

  def save_episode!(href, title, number, date, label, description)
    episode_attributes =
      {
        href: href,
        title: title,
        number: number,
        date: normalize_date(date),
        label: label,
        description: description
      }
    episode = Episode.new(episode_attributes)
    if episode.save
      save_summary(episode)
      Rails.logger.info "Successfully saved episode: #{episode.title}"
    else
      Rails.logger.info "Not saved #{number}"
    end
  end

  #FIXME: data format
  def normalize_date(date)
    DateTime.now
    # DateTime.strptime(date.to_s, "%m-%d-%Y")
  end

  def save_summary(episode)
    path = episode.href
    doc = current_user.get(summary_url(path))
    summary = doc.css('.tab-content')
    episode.update!(fresh_summary: summary)
  end

  def episode_url(number)
     URI.join(ROOT, "/episodes?as_card=true&as_list=false&page=#{number}").to_s
  end

  def summary_url(path)
    URI.join(ROOT, path).to_s
  end

  def current_user
    agent = Mechanize.new
    page = agent.get(SIGN_IN)
    raise(RuntimeError, response_body: 'Something went wrong') unless page.code == '200'

    form = page.forms.first
    form['user[email]'] = ENV['DR_USERNAME']
    form['user[password]'] = ENV['DR_PASSWORD']
    form.submit

    agent
  end
end

