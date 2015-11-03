module GlobTest
include("../src/Glob.jl")
using .Glob
using Base.Test
using Compat

if VERSION < v"0.3-"
    macro test_throws(a,b)
        :( Base.Test.@test_throws($b) )
    end
end

macro test_types(arr, types)
    quote
        @test length($arr) == length($types)
        for i in 1:length($arr)
            @test isa($arr[i], $types[i])
        end
    end
end

# various unit tests, in no particular order

@test !ismatch(fn"abc*", "ABXABXAB")
@test ismatch(fn"AB*AB*AB", "ABXABXAB")
@test ismatch(fn"AB*AB*AB", "ABXABAB")
@test !ismatch(fn"AB*AB*AB", "AABAB")
@test ismatch(fn"AB*AB*AB", "ABABAB")
@test ismatch(fn"AB*AB*B", "ABABAB")
@test ismatch(fn"AB*AB*", "ABABAB")
@test ismatch(fn"AB*AB*??", "ABABAB")
@test !ismatch(fn"AB*AB*???", "ABABAB")
@test ismatch(fn"AB*AB*??***", "ABABAB")
@test ismatch(fn"AB*AB*??***", "ABABABC")
@test ismatch(fn"AB*AB*??***", "ABABABCDEFG")
@test ismatch(fn"?AB*AB*??***", ".ABABABCDEFG")
@test !ismatch(fn"?AB*AB*??***"p, ".ABABABCDEFG")
@test_throws ErrorException Glob.FilenameMatch("?AB*AB*??***","z")
@test ismatch(fn"[abc]", "a")
@test !ismatch(fn"[abc]", "A")
@test ismatch(fn"[abc]"i, "A")
@test ismatch(fn"[abc]", "b")
@test ismatch(fn"[abc]", "c")
@test !ismatch(fn"[abc]", "x")
@test !ismatch(fn"[a-d]", "x")
@test ismatch(fn"[a-d]", "a")
@test ismatch(fn"[a-d]", "d")
@test !ismatch(fn"[a--]", "e")
@test ismatch(fn"[--e]", "e")
@test !ismatch(fn"[f-e]", "e")
@test !ismatch(fn"[g-e]", "e")
@test !ismatch(fn"[g-f]", "e")
@test ismatch(fn"[a-f]", "e")
@test ismatch(fn"[a-e]", "e")
@test ismatch(fn"[f-ee]", "e")
@test !ismatch(fn"[A-Z]", "e")
@test ismatch(fn"[A-z]", "e")
@test ismatch(fn"[\]", "\\")
@test_throws ErrorException ismatch(fn"[[:a:]]", "e")
@test_throws ErrorException !ismatch(fn"[\[:a:]]", "e")
@test !ismatch(fn"[\[:a:]]"x, "e")
@test_throws ErrorException ismatch(fn"[\\[:a:]]", "e")
@test ismatch(fn"[\[:a-e:]]"x, "e]")
@test ismatch(fn"[\[:a-e:]"x, "e")
@test !ismatch(fn"[\[:a-e:xxxx"x, "e")
@test ismatch(fn"[\[:a-e:xxxx-]"x, "e")
@test ismatch(fn"[a-]", "a")
@test ismatch(fn"[a-]", "-")
@test !ismatch(fn"[a-]", "b")
@test ismatch(fn"[!a-]", "b")
@test !ismatch(fn"[!a-]", "a")
@test ismatch(fn"[!a]", "!")
@test !ismatch(fn"[!!]", "!")
@test !ismatch(fn"[!a]", "a")
@test ismatch(fn"[!a]", "b")
@test !ismatch(fn"[][]", "")
@test ismatch(fn"[]", "[]")
@test ismatch(fn"[][]", "[")
@test ismatch(fn"[][]", "]")
@test !ismatch(fn"[][]", "x")
@test !ismatch(fn"[]-[]", "x")
@test !ismatch(fn"[]-[]", "-")
@test !ismatch(fn"[]-[]", "\\")
@test ismatch(fn"[\[-\]]*"x, "][")
@test ismatch(fn"[\]]*"x, "][")
@test ismatch(fn"[\[-\]]*"x, "][")
@test ismatch(fn"[[-\]]*"x, "][")
@test ismatch(fn"base/[\[-\]]*"dpx,"base/][x")
@test ismatch(fn"[\[-\]]"x, "\\")
@test ismatch(fn"[[-\]]"x, "\\")
@test ismatch(fn"[---]", "-")
@test !ismatch(fn"[!---]", "-")
@test ismatch(fn"[!---]", "0")
@test !ismatch(fn"[---a-zA-Z]", "0")
@test !ismatch(fn"[---a-zA-Z:]", "0")
@test !ismatch(fn"[---!]", "0")
@test ismatch(fn"[---!]", "!")
@test !ismatch(fn"[---!]", "a")
@test !ismatch(fn"[---!]", "\0")
@test ismatch(fn"ab/c/d"dp, "ab/c/d")
@test !ismatch(fn"ab/c/d"dp, "ab/c?d")
@test !ismatch(fn"ab/./d"dp, "ab/?/d")
@test !ismatch(fn"ab*d"dp, "aba/d")
@test !ismatch(fn"ab*d"dp, "ab/d")
@test ismatch(fn"ab*d", "ab/d")
@test ismatch(fn"ab*d", "aba/d")
@test ismatch(fn"[a-z]"i, "B")
@test !ismatch(fn"[a-z]"i, "_")
@test ismatch(fn"[A-z]"i, "_")
@test !ismatch(fn"[a-Z]"i, "_")
@test !ismatch(fn"#[a-Z]%"i, "#a%")
@test ismatch(fn"#[α-ω]%"i, "#Γ%")
@test !ismatch(fn"#[α-ω]%", "#Γ%")
@test ismatch(fn"#[α-ω]%", "#γ%")
@test !ismatch(fn"a?b"d, "a/b")
@test ismatch(fn"a?b", "a/b")
@test !ismatch(fn"?b"p, ".b")
@test ismatch(fn"?b", ".b")
@test ismatch(fn"?/?b", "./.b")
@test !ismatch(fn"?/?b"p, "./.b")
@test ismatch(fn"./?b"p, "./.b")
@test !ismatch(fn"./?b"pd, "./.b")
@test ismatch(fn"./.b"pd, "./.b")
@test !ismatch(fn"?/.b"pd, "./.b")
@test ismatch(fn"""./.b"""pd, "./.b")
@test !ismatch(fn"""?/.b"""pd, "./.b")
@test ismatch(fn"_[[:blank:][.a.]-c]_", "_b_")
@test !ismatch(fn"_[[:blank:][.a.]-c]_", "_-_")
@test ismatch(fn"_[[:blank:][.a.]-c]_", "_ _")
@test ismatch(fn"_[[:alnum:]]_", "_a_")
@test !ismatch(fn"_[[:alnum:]]_", "_[_")
@test !ismatch(fn"_[[:alnum:]]_", "_]_")
@test !ismatch(fn"_[[:alnum:]]_", "_:_")
@test ismatch(fn"_[[:alpha:]]_", "_z_")
@test !ismatch(fn"_[[:alpha:]]_", "_[_")
@test ismatch(fn"_[[:cntrl:]]_", "_\0_")
@test ismatch(fn"_[[:cntrl:]]_", "_\b_")
@test !ismatch(fn"_[[:cntrl:]]_", "_:_")
@test !ismatch(fn"_[[:cntrl:]]_", "_ _")
@test ismatch(fn"_[[:digit:]]_", "_0_")
@test !ismatch(fn"_[[:digit:]]_", "_:_")
@test ismatch(fn"_[[:graph:]]_", "_._")
@test !ismatch(fn"_[[:graph:]]_", "_ _")
@test ismatch(fn"_[[:lower:]]_", "_a_")
@test ismatch(fn"_[[:lower:]]_"i, "_A_")
@test !ismatch(fn"_[[:lower:]]_", "_A_")
@test !ismatch(fn"_[[:lower:]]_", "_:_")
@test ismatch(fn"_[[:print:]]_", "_a_")
@test !ismatch(fn"_[[:print:]]_", "_\7_")
@test ismatch(fn"_[[:punct:]]_", "_:_")
@test !ismatch(fn"_[[:punct:]]_", "_p_")
@test ismatch(fn"_[[:space:]]_", "_\f_")
@test !ismatch(fn"_[[:space:]]_", "_:_")
@test !ismatch(fn"_[[:space:]]_", "_\r\n_")
@test ismatch(fn"_[[:upper:]]_", "_A_")
@test ismatch(fn"_[[:upper:]]_"i, "_a_")
@test !ismatch(fn"_[[:upper:]]_", "_a_")
@test !ismatch(fn"_[[:upper:]]_", "_:_")
@test ismatch(fn"_[[:xdigit:]]_", "_a_")
@test !ismatch(fn"_[[:xdigit:]]_", "_:_")
@test ismatch(fn"_[[.a.]-[.z.]]_", "_c_")
@test !ismatch(fn"_[[.a.]-[.z.]]_", "_-_")
@test !ismatch(fn"_[[.a.]-[.z.]]_", "_]_")
@test !ismatch(fn"_[[.a.]-[.z.]]_", "_[_")
@test ismatch(fn"_[[=a=]]_", "_a_")
@test !ismatch(fn"_[[=a=]]_", "_=_")
@test !ismatch(fn"_[[=a=]]_", "_á_")
@test ismatch(fn"[[=a=]-z]", "-")
@test_throws ErrorException ismatch(fn"[a-[=z=]]", "e")

@test !ismatch(fn"\?", "\\?")
@test ismatch(fn"\?", "?")
@test ismatch(fn"\?"e, "\\!")
@test !ismatch(fn"\?"e, "?")

@test_types glob"ab/?/d".pattern (AbstractString, Glob.FilenameMatch, AbstractString)
@test_types glob"""ab/*/d""".pattern (AbstractString, Glob.FilenameMatch, AbstractString)
@test length(glob"ab/[/d".pattern) == 3
@test length(glob"ab/[/]d".pattern) == 3
@test_types glob"ab/[/]d".pattern (AbstractString, AbstractString, AbstractString)
@test_types glob"ab/[/d".pattern (AbstractString, AbstractString, AbstractString)
@test_types glob"ab/[]/d".pattern (AbstractString, AbstractString, AbstractString)
@test_types glob"ab/[]]/d".pattern (AbstractString, Glob.FilenameMatch, AbstractString)

@test glob("*") == filter(x->!startswith(x,'.'), readdir()) == readdir(glob"*")
@test glob(".*") == filter(x->startswith(x,'.'), readdir()) == readdir(glob".*")
@test isempty(Glob.glob("[.]*"))
@test glob([r".*"]) == readdir()
@test glob([".", r".*"]) == map(x->joinpath(".",x), readdir())
@test all([!startswith(x,'.') for x in Glob.glob("*.*")])

function test_string(x1)
    x2 = string(eval(parse(x1)))
    x1 == x2 ? nothing : error(string(
        "string test failed:",
        "\noriginal: ", x1,
        "\n\nstringify: ", x2))
end
test_string("""Glob.GlobMatch(Any["base",r"h\.+"])""")
test_string("""glob"base/*/a/[b]\"""")
test_string("""fn"base/*/a/[b]\"ipedx""")
test_string("""fn"base/*/a/[b]\"""")

@test_throws ErrorException Glob.GlobMatch("")
@test_throws ErrorException Glob.GlobMatch("/a/b/c")

end
