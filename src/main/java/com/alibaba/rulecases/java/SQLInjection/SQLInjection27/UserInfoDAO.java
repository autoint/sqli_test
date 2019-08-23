package com.alibaba.rulecases.java.SQLInjection.SQLInjection27;
import java.util.List;

public interface UserInfoDAO {
	List<UserInfoDO> query(UserInfoQuery userInfoQuery);
}
