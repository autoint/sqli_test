package com.alibaba.rulecases.java.SQLInjection.SQLInjection28;
import java.util.List;

public interface UserInfoDAO {
	List<UserInfoDO> query(UserInfoQuery userInfoQuery);
}
