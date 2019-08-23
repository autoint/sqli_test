package com.alibaba.rulecases.java.SQLInjection.SQLInjection40;
import java.util.List;

import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.SelectProvider;

public interface UserInfoDAO {
	@SelectProvider(type = SqlProvider.class, method = "query")
	List<UserInfoDO> query(@Param("userInfoQuery") UserInfoQuery userInfoQuery);
}
