module Patterns
    Holder_extractor = /\(<F53621>(?<loc_code>(a|h|bpl|y-brbl|y-mssa))<F255>( (1896)?<F53621>(?<subloc_code>(b|h|l|st|mlt|mtb|pc|to|tr))<F255>(, )?)?(?<id>[^\)]*)\)/

    Title_pattern = /(Y_PNT_PNT|@PNT[^\d]|@PNT2_1|Y_PNT2_PNT2)/ 
    Title_extractor = /= (?<number>\d*)\t(?<title>[^\r\n]*)/

    Variant_title_extractor = /@PNT2_2(_M)? = \t(?<title>.*$)/

    Poem_start_pattern = /(@PS|@POEM1S)/
    Poem_end_pattern = /^(@N|@1|@VAR|@PARA)/

    Division_pattern = /@N = <MI>Division<D>/
    Division_extractor = /@N = <MI>Division<D>(?<divisions>.*)/

    Emendation_pattern = /@N(_3PTS)? = <MI>Emendation<D>/
    Emendation_extractor = /@N(_3PTS)? = <MI>Emendation<D>(?<emendations>.*)/

    Publication_pattern = /^@1 = <F53621M?(%14)?>publication(<D?%0>)?:<F255>/
    Publication_extractor = /^@1 = <F53621M?(%14)?>publication(<D?%0>)?:<F255>(?<publications>.*)/
    Published_extractor = /<MI>(?<publication>[^<]*)<D> \(((?<day>\d{1,2}) (?<month>\w*) )?(?<year>\d{4})\), (?<pages>[-\d]+)( \(<MI>(?<source_variant>[A-Z])<D>\))?/

    Revision_pattern = /@VAR(_VS)? = <MI>Revision<D>/
    Revision_extractor = /@VAR(_VS)? = <MI>Revision<D>(?<revisions>.*)/

    Ignore_next_line_pattern = /^@PARA = .*variant.*:/i
    Alternate_pattern = /@VAR(_VS)? =/
    Alternate_extractor = /@VAR(_VS)? = (?<alternates>.*)/

    Stanza_start_pattern = Poem_start_pattern
    Stanza_boundary_pattern = /@PMS/

    Poem_line_extractors = [
        /(@PS|@PM|@PMS|@POEM1M|@POEM1S|@PE) = <P9(MI)?>(?<variant>.*)<P255(D)?> ?\t(?<line>[^\t\r\n]*)/,
        /(@PS|@PM|@PMS|@POEM1M|@POEM1S|@PE) = <P9(MI)?>(?<variant>.*)<P255(D)?> ?\t(?<line>[^\t\r\n]*)\t(?<fascicle>[^\r\n]*)?/,
        /(@PS|@PM|@PMS|@POEM1M|@POEM1S|@PE) = \t(?<line>[^\r\n]*)/,
        /(@PS|@PM|@PMS|@POEM1M|@POEM1S|@PE) = \t(?<line>[^\t]*)\t(?<line_num>\d*)/,
        /@PS = (<F58586P9M>)?\[<MI>(?<variant>.*)<(D|M)>\](<F255P255D>)?\t(?<line>[^\t]*)\t?(?<line_num>\d*)/
    ]
end