require 'rails_helper'

feature 'Select another founder profile as the active profile' do
  include UserSpecHelper

  # Two startups.
  let(:startup_1) { create :startup, :subscription_active }
  let(:startup_2) { create :startup, :subscription_active }

  # Add milestone target groups for both schools, so that the dashboard will render correctly.
  let(:target_group_s1) { create :target_group, level: startup_1.level, milestone: true }
  let!(:target_s1) { create :target, target_group: target_group_s1 }
  let(:target_group_s2) { create :target_group, level: startup_2.level, milestone: true }
  let!(:target_s2) { create :target, target_group: target_group_s2 }

  # One team lead is also a founder in the other.
  let!(:multi_founder_user) { startup_1.team_lead.user }
  let!(:founder_in_s2) { create :founder, startup: startup_2, user: multi_founder_user }
  let(:single_founder_user) { startup_2.team_lead.user }

  scenario 'Multi-founder user can switch between schools' do
    sign_in_user multi_founder_user, referer: root_path

    click_link("#{startup_2.school.name} School")

    expect(page).to have_selector('#founder-dashboard')
    expect(page).to have_content(startup_2.product_name)

    # ...and back to the first school?
    click_link("#{startup_1.school.name} School")

    expect(page).to have_selector('#founder-dashboard')
    expect(page).to have_content(startup_1.product_name)
  end

  scenario 'Single-founder user does not have option to switch between schools' do
    sign_in_user single_founder_user, referer: root_path

    School.all.each do |school|
      expect(page).not_to have_link("#{school.name} School")
    end
  end
end
