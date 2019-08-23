package com.alibaba.rulecases.java.SQLInjection.SQLInjection55;

import java.util.Map;

import org.apache.ibatis.annotations.Select;

import com.alibaba.dxp.daoproxy.annotation.*;

@Dao("resourceTextDAO")
public interface ResourceTextDAO {
	@Select("")
	Integer queryWdkResourceTextCountByModuleId(Map<String, Object> map);
}
