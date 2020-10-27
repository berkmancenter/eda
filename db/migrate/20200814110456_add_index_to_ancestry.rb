class AddIndexToAncestry < ActiveRecord::Migration[5.2]
  def change
    # Speed up LIKEs on the ancestry column
    execute <<-SQL
      CREATE INDEX ancestry_on_setts_text_full ON setts (ancestry text_pattern_ops);
    SQL
  end
end
