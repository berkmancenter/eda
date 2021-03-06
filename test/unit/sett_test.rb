require 'test_helper'

class SettTest < ActiveSupport::TestCase

  def setup
    (Sett.first.rankers.first.with Sett.first).send(:rebalance_ranks)
  end

  test "root is root" do
    roots = Sett.roots
    assert roots.count == 5
  end

  test "leaves" do
    leaves = Sett.find(1).leaves
    assert leaves.count == 7
    assert leaves.map(&:id).sort == [4, 5, 7, 9, 10, 13, 14]
  end

  test "moving a node up" do
    assert Sett.find(8).children.first.id == 9 
    assert Sett.find(8).children.last.id == 11
    Sett.find(8).children.last.move_up
    assert Sett.find(8).children.first.id == 9
    assert Sett.find(8).children.last.id == 10
  end

  test "moving a node down" do
    assert Sett.find(1).children.first.id == 2 
    assert Sett.find(1).children.last.id == 8
    Sett.find(2).move_down
    assert Sett.find(1).children.first.id == 6
    assert Sett.find(1).children.last.id == 8
  end

  test "move to child of" do
    s = Sett.find(2)
    assert s.parent_id == 1
    s.move_to_child_of(Sett.find(6))
    s.save!
    assert s.parent_id == 6
    assert s.prev_siblings.first.id == 7
  end

  test "self and descendants" do
    assert Sett.find(2).self_and_descendants.map(&:id) == [2, 3, 4, 5]
    assert Sett.find(57).self_and_descendants.map(&:id) == [57, 56, 59, 58, 60, 61]
  end

  test "self and ancestors" do
    assert Sett.find(4).self_and_ancestors.map(&:id).sort == [1, 2, 3, 4]
    assert Sett.find(5).self_and_ancestors.map(&:id).sort == [1, 2, 5]
    assert Sett.find(9).self_and_ancestors.map(&:id).sort == [1, 8, 9]
  end

  test "next siblings" do
    assert Sett.find(2).next_siblings.map(&:id).sort == [6, 8]
    assert Sett.find(9).next_siblings.map(&:id).sort == [10, 11]
    assert Sett.find(11).next_siblings.empty?
  end

  test "previous siblings" do
    assert Sett.find(11).prev_siblings.pluck(:id) == [10, 9]
    assert Sett.find(5).prev_siblings.pluck(:id) == [3]
    assert Sett.find(1).prev_siblings.empty?
  end

  test "leaves after leaf" do
    root = Sett.find(1)
    assert root.leaves_after(Sett.find(4)).count == 6
    assert root.leaves_after(Sett.find(4)).first.id == 5
    assert root.leaves_after(Sett.find(5)).count == 5
    assert root.leaves_after(Sett.find(5)).first.id == 7
    assert root.leaves_after(Sett.find(7)).first.id == 9
    assert root.leaves_after(Sett.find(9)).first.id == 10
    assert root.leaves_after(Sett.find(10)).first.id == 13
    assert Sett.find(2).leaves_after(Sett.find(4)).count == 1
    assert Sett.find(2).leaves_after(Sett.find(4)).first.id == 5
  end

  test "leaf after leaf" do
    root = Sett.find(1)
    assert root.leaf_after(Sett.find(4)).id == 5
    assert root.leaf_after(Sett.find(5)).id == 7
    assert root.leaf_after(Sett.find(7)).id == 9
    assert root.leaf_after(Sett.find(9)).id == 10
    assert root.leaf_after(Sett.find(10)).id == 13
    assert Sett.find(15).leaf_after(Sett.find(16)).id == 18
    assert Sett.find(2).leaf_after(Sett.find(5)).nil?
  end

  test "leaf after non-leaf" do
    root = Sett.find(1)
    assert root.leaf_after(Sett.find(3)).id == 5
    assert root.leaf_after(Sett.find(6)).id == 9
    assert root.leaf_after(Sett.find(2)).id == 7
    assert Sett.find(8).leaf_after(Sett.find(11)).nil?
  end

  test "leaves before leaf" do
    root = Sett.find(1)
    assert root.leaves_before(Sett.find(4)).empty?
    assert root.leaves_before(Sett.find(5)).first.id == 4
    assert root.leaves_before(Sett.find(10)).count == 4
    assert root.leaves_before(Sett.find(9)).pluck(:id).sort == [4, 5, 7]
    assert root.leaves_before(Sett.find(13)).pluck(:id).sort == [4, 5, 7, 9, 10]
    assert Sett.find(8).leaves_before(Sett.find(14)).count == 3
  end

  test "leaf before leaf" do
    root = Sett.find(1)
    assert root.leaf_before(Sett.find(5)).id == 4
    assert root.leaf_before(Sett.find(7)).id == 5
    assert root.leaf_before(Sett.find(9)).id == 7
    assert root.leaf_before(Sett.find(10)).id == 9
    assert root.leaf_before(Sett.find(13)).id == 10
    assert Sett.find(49).leaf_before(Sett.find(52)).id == 51
    assert Sett.find(49).leaf_before(Sett.find(54)).id == 52
    assert Sett.find(2).leaf_before(Sett.find(4)).nil?
    assert Sett.find(15).leaf_before(Sett.find(19)).id == 18
  end

  test "leaf before non-leaf" do
    root = Sett.find(1)
    assert root.leaf_before(Sett.find(3)).nil?
    assert root.leaf_before(Sett.find(11)).id == 10
    assert root.leaf_before(Sett.find(8)).id == 7
  end

  test "position in level" do
    assert Sett.find(3).position_in_level == 0
    assert Sett.find(5).position_in_level == 1
    assert Sett.find(6).position_in_level == 1
    assert Sett.find(8).position_in_level == 2
    assert Sett.find(10).position_in_level == 1
    assert Sett.find(12).position_in_level == 0
  end

  test "duplication" do
    assert Sett.find(13).ancestor_ids == [1, 8, 11, 12]
    dup = Sett.find(1).duplicate
    assert Sett.find(dup.id + 13).ancestor_ids == [
      dup.id,
      dup.id + 7,
      dup.id + 10,
      dup.id + 11
    ]
  end

  test "updating leaf status" do
    assert Sett.find(13).is_leaf
    s = Sett.create
    s.move_to_child_of Sett.find(13)
    s.save!
    assert !Sett.find(13).is_leaf
  end
end
