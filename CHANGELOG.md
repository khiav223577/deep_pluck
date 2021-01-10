## Change Log

### [v1.1.5](https://github.com/khiav223577/deep_pluck/compare/v1.1.4...v1.1.5) 2021/01/10
- [#39](https://github.com/khiav223577/deep_pluck/pull/39) Compatibility with Rails 6.1.1 (@klausbadelt)
- [#40](https://github.com/khiav223577/deep_pluck/pull/40) Exclude tests from coverage (@klausbadelt)

### [v1.1.4](https://github.com/khiav223577/deep_pluck/compare/v1.1.3...v1.1.4) 2020/01/13
- [#36](https://github.com/khiav223577/deep_pluck/pull/36) A workaround to fix mismatched association named. (@khiav223577)
- [#35](https://github.com/khiav223577/deep_pluck/pull/35) Support Ruby 2.7 (@khiav223577)

### [v1.1.3](https://github.com/khiav223577/deep_pluck/compare/v1.1.2...v1.1.3) 2019/12/17
- [#34](https://github.com/khiav223577/deep_pluck/pull/34) Support for plucking directly on a has_one through association (@khiav223577)

### [v1.1.2](https://github.com/khiav223577/deep_pluck/compare/v1.1.1...v1.1.2) 2019/09/25
- [#32](https://github.com/khiav223577/deep_pluck/pull/32) Remove unneeded `PreloadedModel` (@khiav223577)
- [#31](https://github.com/khiav223577/deep_pluck/pull/31) Support Rails 6.0 (@khiav223577)
- [#30](https://github.com/khiav223577/deep_pluck/pull/30) Lock sqlite3 version to 1.3.x (@khiav223577)
- [#28](https://github.com/khiav223577/deep_pluck/pull/28) Fix: broken test cases after bundler 2.0 was released (@khiav223577)
- [#27](https://github.com/khiav223577/deep_pluck/pull/27) Remove deprecated codeclimate-test-reporter gem and update travis config (@khiav223577)

### [v1.1.1](https://github.com/khiav223577/deep_pluck/compare/v1.1.0...v1.1.1) 2018/07/08
- [#26](https://github.com/khiav223577/deep_pluck/pull/26) Fix: `id` may disappear when plucking at model instance (@khiav223577)
- [#25](https://github.com/khiav223577/deep_pluck/pull/25) Refactor - move models definition to separate files (@khiav223577)
- [#24](https://github.com/khiav223577/deep_pluck/pull/24) test Rails 5.2 (@khiav223577)
- [#23](https://github.com/khiav223577/deep_pluck/pull/23) should test both 5.0.x and 5.1.x (@khiav223577)
- [#22](https://github.com/khiav223577/deep_pluck/pull/22) #deep_pluck at active model without plucking deeply will cause ArgumentError (@khiav223577)
- [#20](https://github.com/khiav223577/deep_pluck/pull/20) [ENHANCE] Eliminate Extra Select Loop in Hash Lookup (@berniechiu)

### [v1.1.0](https://github.com/khiav223577/deep_pluck/compare/v1.0.3...v1.1.0) 2018/02/15
- [#19](https://github.com/khiav223577/deep_pluck/pull/19) Support deep_pluck at active model (@khiav223577)
- [#18](https://github.com/khiav223577/deep_pluck/pull/18) Add rubocop and Improve code quality (@khiav223577)

### [v1.0.3](https://github.com/khiav223577/deep_pluck/compare/v1.0.2...v1.0.3) 2017/06/30
- [#15](https://github.com/khiav223577/deep_pluck/pull/15) test deep_pluck in rails 5.1.x (@khiav223577)
- [#14](https://github.com/khiav223577/deep_pluck/pull/14) Handle polymorphic associations correctly. (@Bogadon)

### [v1.0.0](https://github.com/khiav223577/deep_pluck/compare/v0.1.4...v1.0.0) 2017/03/28
- [#12](https://github.com/khiav223577/deep_pluck/pull/12) reduce cyclomatic complexity in model.rb (@khiav223577)

### [v0.1.4](https://github.com/khiav223577/deep_pluck/compare/v0.1.3...v0.1.4) 2017/03/27
- [#11](https://github.com/khiav223577/deep_pluck/pull/11) Fix conditional associations (@khiav223577)

### [v0.1.3](https://github.com/khiav223577/deep_pluck/compare/v0.1.2...v0.1.3) 2017/03/20
- [#10](https://github.com/khiav223577/deep_pluck/pull/10) fix custom foreign_key, custom primary_key issues (@khiav223577)
- [#9](https://github.com/khiav223577/deep_pluck/pull/9) fix has_and_belongs_to_many (@khiav223577)

### [v0.1.2](https://github.com/khiav223577/deep_pluck/compare/v0.1.1...v0.1.2) 2017/03/17
- [#8](https://github.com/khiav223577/deep_pluck/pull/8) fix some need columns is missing (@khiav223577)
- [#7](https://github.com/khiav223577/deep_pluck/pull/7) raise error message when association not found (@khiav223577)

### [v0.1.1](https://github.com/khiav223577/deep_pluck/compare/v0.1.0...v0.1.1) 2017/03/16
- [#6](https://github.com/khiav223577/deep_pluck/pull/6) fix deep_pluck with #joins (@khiav223577)

### [v0.1.0](https://github.com/khiav223577/deep_pluck/compare/v0.0.4...v0.1.0) 2017/03/15
- [#5](https://github.com/khiav223577/deep_pluck/pull/5) Support pluck many-to-many associations (@khiav223577)

### [v0.0.4](https://github.com/khiav223577/deep_pluck/compare/v0.0.3...v0.0.4) 2017/03/14
- [#4](https://github.com/khiav223577/deep_pluck/pull/4) Fix use deep_pluck on NullRelation will raise exception and prevent unneeded query. (@khiav223577)

### [v0.0.3](https://github.com/khiav223577/deep_pluck/compare/v0.0.2...v0.0.3) 2017/03/06
- [#3](https://github.com/khiav223577/deep_pluck/pull/3) support more than two level (@khiav223577)

### [v0.0.2](https://github.com/khiav223577/deep_pluck/compare/v0.0.1...v0.0.2) 2017/03/06
- [#2](https://github.com/khiav223577/deep_pluck/pull/2) The result of has_one association should not be array (@khiav223577)

### v0.0.1 2017/03/04
- [#1](https://github.com/khiav223577/deep_pluck/pull/1) deep pluck (@khiav223577)
