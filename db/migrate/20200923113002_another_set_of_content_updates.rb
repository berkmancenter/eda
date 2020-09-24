class AnotherSetOfContentUpdates < ActiveRecord::Migration[5.2]
  def change
    # F1713A "With sweetness unabashed" should display Image Unavailable (this image not sent)
    work = Work.where(number: 1713, variant: 'A').first
    current_work_image_set = work.edition.image_set.leaves_showing_work(work).first
    current_work_image_set.image.url = nil
    current_work_image_set.image.save

    # F1714A, J1669 "In snow thou comest" should display Image Unavailable (this image not sent)
    work = Work.where(number: 1714, variant: 'A').first
    current_work_image_set = work.edition.image_set.leaves_showing_work(work).first
    current_work_image_set.image.url = nil
    current_work_image_set.image.save

    work = Work.where(number: 1669, edition_id: 2).first
    current_work_image_set = work.edition.image_set.leaves_showing_work(work).first
    current_work_image_set.image.url = nil
    current_work_image_set.image.save

    # Tie the Strings to my Life, My Lord, This is now fine when you choose the F338A
    # from search, but if you choose J279 it links to the second page of that poem:
    # http://qa.edickinson.org/editions/2/image_sets/12192912, and the Johnson text
    # is in the wrong order. "Tie the strongs" text should be on top, and "I like
    # a look of Agony" on the bottom.
    work = Work.where(number: 279, variant: nil).first
    work.image_set.move_left
    work.image_set.save
    image = Image.create(
      url: 'ms_am_1118_3_53_0001'
    )
    current_work_image_set = work.edition.image_set.leaves_showing_work(work).first
    new_image_set = current_work_image_set.duplicate
    new_image_set.image = image
    new_image_set.move_to_child_of(current_work_image_set.parent)
    new_image_set.save
    new_image_set.move_right
    new_image_set.move_left
    new_image_set.move_left
    new_image_set.save

    # F817A "This consciousness that is aware" is linked correctly, but the verso
    # (with address "Sue") doesn't display. I think this is because there's no option
    # box to switch from Edition to Library (and hence Reading View). The image sent
    # was labeled F817Ap2. When I try using the right arrow, I get an error message.
    image_set = ImageSet.new
    image_set.is_leaf = true
    image_set.ancestry_depth = 1,
    image_set.ancestry = Work.where(number: '817', variant: 'A').first.image_set.id,
    image_set.nestable_id = Image.where(url: 'F817Ap2').first.id
    image_set.nestable_type = 'Image'
    image_set.save

    # In the image credits (tray beneath displayed image) the repository name is
    # a hot link. The Houghton link need to be changed to https://library.harvard.edu/collections/emily-dickinson-collection
    ActiveRecord::Base.connection.execute("UPDATE images SET credits = replace(credits, 'http://hcl.harvard.edu/libraries/houghton/collections/modern/dickinson.cfm', 'https://library.harvard.edu/collections/emily-dickinson-collection')")

    # The new partners added should also be hot links: Dumbarton Oaks,
    # Jones Library, Morgan Library, NYPL, Rosenbach. The URLs are all on the
    # "About --> Partners" page. ​Also, each new image added needs full credits. Here's an example:
    # Credits
    # Houghton Library, Harvard University, Cambridge, MA
    # Dickinson, Emily, 1830-1886. Poems: Packet XL, Fascicle 32. Includes 21 poems, written in ink, ca. 1862.
    # Houghton Library - (215a) Sweet - safe - Houses -, J457, Fr684
    # Publication History
    # BM (1945), 203, from a transcript of A (a tr409), as four quatrains. Poems (1955), 352-53; CP (1960), 219-20. MB (1981), 765, in facsimile. (J457). Franklin Variorum 1998 (F684A).
    # -History from Franklin Variorum 1998
    #
    # Emily Dickinson Archive
    # http://www.edickinson.org
    # Copyright & Terms of Use:
    # # CC BY-NC-ND 3.0
    # # http://www.edickinson.org/terms
    copyright_text = '<br><br>Emily Dickinson Archive<br>http://www.edickinson.org<br>Copyright & Terms of Use:<br>CC BY-NC-ND 3.0<br>http://www.edickinson.org/terms'
    # Dumbarton Oaks
    link = '<a href="https://www.doaks.org/research/library-archives" target="_blank">Dumbarton Oaks Research Library and Collections, Rare Book Collection. Washington, D.C.</a>'
    image_set = ImageSet.where(name: 'Dumbarton Oaks, Harvard University', ancestry_depth: 0).first
    images_ids = []
    image_set.descendants.each do |descendant|
      images_ids << descendant.image.id
    end
    old_title = 'Dumbarton Oaks Research Library and Collection, Rare Book Collection. Washington, D.C.'
    ActiveRecord::Base.connection.execute("UPDATE images SET credits = replace(credits, '#{old_title}', '') WHERE id IN (#{images_ids.join(',')})")
    ActiveRecord::Base.connection.execute("UPDATE images SET credits = concat('#{link}', credits, '#{copyright_text}') WHERE id IN (#{images_ids.join(',')})")

    # Morgan Library
    link = '<a href="https://www.themorgan.org/" target="_blank">The Morgan Library & Museum. New York, NY</a>'
    image_set = ImageSet.where(name: 'The Morgan Library & Museum', ancestry_depth: 0).first
    images_ids = []
    image_set.descendants.each do |descendant|
      images_ids << descendant.image.id
    end
    old_title = 'The Morgan Library & Museum. New York, NY.'
    ActiveRecord::Base.connection.execute("UPDATE images SET credits = replace(credits, '#{old_title}', '') WHERE id IN (#{images_ids.join(',')})")
    ActiveRecord::Base.connection.execute("UPDATE images SET credits = concat('#{link}', credits, '#{copyright_text}') WHERE id IN (#{images_ids.join(',')})")

    # Jones Library
    link = '<a href="https://www.joneslibrary.org/211/Special-Collections" target="_blank">Jones Library Special Collections. Amherst, MA</a><br>'
    image_set = ImageSet.where(name: 'Jones Library', ancestry_depth: 0).first
    images_ids = []
    image_set.descendants.each do |descendant|
      images_ids << descendant.image.id
    end
    ActiveRecord::Base.connection.execute("UPDATE images SET credits = concat('#{link}', credits, '#{copyright_text}') WHERE id IN (#{images_ids.join(',')})")

    # New York Public Library
    link = '<a href="http://www.nypl.org/" target="_blank">New York Public Library, Berg Collection, and Archives and Manuscripts. New York, NY</a><br>'
    image_set = ImageSet.where(name: 'New York Public Library', ancestry_depth: 0).first
    images_ids = []
    image_set.descendants.each do |descendant|
      images_ids << descendant.image.id
    end
    ActiveRecord::Base.connection.execute("UPDATE images SET credits = concat('#{link}', credits, '#{copyright_text}') WHERE id IN (#{images_ids.join(',')})")

    # The Rosenbach
    link = '<a href="https://rosenbach.org/" target="_blank">The Rosenbach of the Free Library of Philadelphia. Philadelphia, PA</a>'
    image_set = ImageSet.where(name: 'The Rosenbach', ancestry_depth: 0).first
    images_ids = []
    image_set.descendants.each do |descendant|
      images_ids << descendant.image.id
    end
    old_title = 'The Rosenbach of the Free Library of Philadelphia, Philadelphia, PA.'
    ActiveRecord::Base.connection.execute("UPDATE images SET credits = replace(credits, '#{old_title}', '') WHERE id IN (#{images_ids.join(',')})")
    ActiveRecord::Base.connection.execute("UPDATE images SET credits = concat('#{link}', credits, '#{copyright_text}') WHERE id IN (#{images_ids.join(',')})")

    # Susan Dickinson transcriptions (two images added): I realize now I should have
    # sent you a spreadsheet with metadata; this is attached, as the last sheet in
    # the set. I went back and double-checked the images I sent you, and realized
    # I'd given you some wrong info. My apologies! The spreadsheet makes it clearer,
    # and separately I'll send two images that I thought I'd sent, but couldn't
    # find in my sent-mail.
    work_1686_a = Work.where(number: 1686, variant: 'A').first
    work_1687_a = Work.where(number: 1687, variant: 'A').first
    work_1688_a = Work.where(number: 1688, variant: 'A').first
    current_work_image_set_86 = work_1686_a.edition.image_set.leaves_showing_work(work_1686_a).first
    current_work_image_set_87 = work_1687_a.edition.image_set.leaves_showing_work(work_1687_a).first
    current_work_image_set_88 = work_1688_a.edition.image_set.leaves_showing_work(work_1688_a).first
    current_work_image_set_86.image.url = current_work_image_set_87.image.url = current_work_image_set_88.image.url = 'ms_am_1118_96_54_HST1_0001'
    current_work_image_set_86.image.credits = current_work_image_set_87.image.credits = current_work_image_set_88.image.credits = '<a href="https://library.harvard.edu/collections/emily-dickinson-collection">Houghton Library, Harvard University. Cambridge, MA</a><br>Martha Dickinson Bianchi Papers. MS Am 1118.96 (54), ST1a-c<br>Susan Dickinson transcripts: The gleam of an heroic act; Beauty crowds me til I die; Endanger it, and the demand' + copyright_text
    current_work_image_set_86.image.save
    current_work_image_set_87.image.save
    current_work_image_set_88.image.save

    work_1689_a = Work.where(number: 1689, variant: 'A').first
    work_1288_b = Work.where(number: 1288, variant: 'B').first
    current_work_image_set_89 = work_1689_a.edition.image_set.leaves_showing_work(work_1689_a).first
    current_work_image_set_88 = work_1288_b.edition.image_set.leaves_showing_work(work_1288_b).first
    current_work_image_set_89.image.url = current_work_image_set_88.image.url = 'ms_am_1118_96_54_HST1_0002'
    current_work_image_set_89.image.credits = current_work_image_set_88.image.credits = '<a href="https://library.harvard.edu/collections/emily-dickinson-collection">Houghton Library, Harvard University. Cambridge, MA</a><br>Martha Dickinson Bianchi Papers. MS Am 1118.96 (54), ST1d-e<br>Susan Dickinson transcripts: To tell the beauty would decrease; Elijah\'s wagon knew no thrill' + copyright_text
    current_work_image_set_88.image.save
    current_work_image_set_89.image.save

    work_1714_a = Work.where(number: 1714, variant: 'A').first
    work_1715_a = Work.where(number: 1715, variant: 'A').first
    current_work_image_set_1714 = work_1714_a.edition.image_set.leaves_showing_work(work_1714_a).first
    current_work_image_set_1715 = work_1715_a.edition.image_set.leaves_showing_work(work_1715_a).first
    current_work_image_set_1714.image.url = 'F1715A_p1'
    current_work_image_set_1714.image.credits = current_work_image_set_1715.image.credits = '<a href="https://library.harvard.edu/collections/emily-dickinson-collection">Houghton Library, Harvard University. Cambridge, MA</a><br>Martha Dickinson Bianchi Papers. MS Am 1118.96 (54), ST4b-e<br>Susan Dickinson transcripts: In sorrow thou comest; A word made flesh is seldom' + copyright_text
    current_work_image_set_1714.image.save
    current_work_image_set_1715.image.save

    work_1715_ap2 = Work.where(number: 1715, variant: 'A').first
    current_work_image_set_1714p2 = work_1715_ap2.edition.image_set.leaves_showing_work(work_1715_ap2).second
    current_work_image_set_1714p2.image.credits = '<a href="https://library.harvard.edu/collections/emily-dickinson-collection">Houghton Library, Harvard University. Cambridge, MA</a><br>Martha Dickinson Bianchi Papers. MS Am 1118.96 (54), ST4b-e<br>Susan Dickinson transcripts: In sorrow thou comest; A word made flesh is seldom' + copyright_text
    current_work_image_set_1714p2.image.save
  end
end
