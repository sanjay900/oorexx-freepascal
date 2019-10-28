call RxFuncAdd "rexxwebversion", "rexxsample", "rxxwebversion"
call RxFuncAdd "callrexx", "rexxsample", "callrexx"
call rexxwebversion
say result
call callrexx "test2.rex", "test", "test2", "test3"
say result