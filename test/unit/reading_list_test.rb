require 'test_helper'

class ReadingListTest < ActiveSupport::TestCase
  test 'add many works' do
    rl = ReadingList.first
    assert rl.works.count == 0
    rl.works = Work.where(number: [1, 2, 3])
    assert rl.works.count == 4
    rl.works = Work.where(number: [1, 3])
    assert rl.works.count == 2
  end

  test 'add one work' do
    rl = ReadingList.first
    assert rl.works.count == 0
    work = Work.first
    rl.add_work(work)
    assert rl.works.count == 1
    assert rl.works.first.id == work.id
  end

  test 'contains work?' do 
    rl = ReadingList.first
    assert rl.works.count == 0
    rl.works = Work.where(number: [1, 2, 3])
    assert rl.works.count == 4
    assert rl.contains_work?(Work.find_by_number(1))
    assert !rl.contains_work?(Work.find_by_number(4))
  end
end
