call RxFuncAdd "rexxversion", "rexxsample", "rexxversion"
say result
call RxFuncAdd "callrexx", "rexxsample", "callrexx"
say result
call rexxversion
say result
call callrexx "test2.rex", "test", "test2", "test3"
say result