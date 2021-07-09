package com.group5.springboot.controller.cart;

import java.util.*;


import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.validation.ObjectError;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.group5.springboot.model.cart.OrderInfo;
import com.group5.springboot.service.cart.OrderService;
import com.group5.springboot.validate.OrderValidator;

@Controller
public class CartViewController {
	@Autowired
	private OrderService orderService;
	@Autowired
	private OrderValidator orderValidator;

	/**OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO */
	@GetMapping(value = {"/order.controller/adminInsert"})
	public String toOrderAdminInsert(Model model) {
		model.addAttribute("emptyOrderInfo", new OrderInfo());
		return "/cart/orderAdminInsert";
	}
	
	/**OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO */
	@PostMapping(value = {"/order.controller/adminInsert"})
	public String orderAdminInsert(@ModelAttribute("emptyOrderInfo") OrderInfo orderInfo,
			BindingResult result, 
			RedirectAttributes ra) {
		
		orderValidator.validate(orderInfo, result);
		if (result.hasErrors()) {			
			List<ObjectError> list = result.getAllErrors();
			list.forEach(objectError -> System.out.println("有錯誤：" + objectError));
			return "/cart/orderAdminInsert";
//			return "redirect:/order.controller/adminInsert"; // ❓
		}
		
		orderService.insert(orderInfo);
		ra.addFlashAttribute("successMessage", "訂單編號 = " + orderInfo.getO_id() + "新增成功！");
		return "redirect:/order.controller/adminSelect";
	}
	
	/**OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO */
	@GetMapping(value = {"/order.controller/adminUpdate/{oid}"})
	public String toOrderAdminUpdate(@PathVariable("oid") Integer oid, Model model) {
		model.addAttribute("orderInfo", orderService.select(new OrderInfo(oid)).get("orderInfo"));
		return "/cart/orderAdminUpdate";
//		return "redirect:/order.controller/adminUpdate"; // ❓
	}
	
	/**OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO */
	@PostMapping(value = {"/order.controller/adminUpdate/{oid}"})
	public String orderAdminUpdate(@ModelAttribute(name = "orderInfo") OrderInfo orderInfo,
			BindingResult result, 
			RedirectAttributes ra) {
		
		orderValidator.validate(orderInfo, result);
		if (result.hasErrors()) {
			List<ObjectError> list = result.getAllErrors();
			list.forEach(objectError -> System.out.println("有錯誤：" + objectError));
			return "/cart/orderAdminUpdate";
		}
		
		orderService.update(orderInfo);
		ra.addFlashAttribute("successMessage", "o_id = " + orderInfo.getO_id() + "修改成功");
		return "redirect:/order.controller/adminSelect";
		
	}
	
	/**OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO */
	@GetMapping(value = {"/cart.controller/cartIndex"})
	public String toCartIndex() {
		return "cart/cartIndex";
	}
	
	/**OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO */
	@PostMapping(value = {"/cart.controller/cartCheckout"})
	public String toCartCheckout() {
		return "cart/cartCheckout";
	}
	
	/**OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO */
	@GetMapping(value = {"/order.controller/adminSelect"})
	public String toCartAdminSelect() {
		return "cart/orderAdminSelect";
	}
	
	/**OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO */
//	@GetMapping(value = "/cart.controller/index")
//	public String backToMainPage() {
//		return "/index";
//	}
	
	/**OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO */
//	@PostMapping("/cart.controller/pay")
//	public String pay() {
//
//		User_Info fakeUserInfo00 = new User_Info();
//		fakeUserInfo00.setU_id("fbk001");
//		
//		// 取得O_Amt
//		 Integer O_Amt = 0;
//		 for (int i = 0; i < this.cart.size(); i++) {
//			O_Amt += this.cart.get(i).getP_Price();
//		}
//		 
//		// 把OrderBean的資料寫進去Database
//		for(int i = 0; i < cart.size(); i++) {
//			OrderInfo orderBean = new OrderInfo();
//			orderBean.setO_id(1000); // PK // 會受IDENTITY(1, 1)的影響被複寫掉，值是多少都無所謂 // ❗
//			orderBean.setP_id(cart.get(i).getP_ID()); // FK
//			orderBean.setU_id(fakeUserInfo00.getU_id()); // FK // fake
//			orderBean.setO_amt(O_Amt);
//			orderService.insert(orderBean);
//		}
//
//		this.cart = new ArrayList<ProductInfo>();
//		System.out.println("購買成功，感謝您！");
//		return "/cart/cartThanks";
//	}
	
	/**OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO */
	@SuppressWarnings("unchecked")
	@ModelAttribute("selectedRowNum")
	public Integer getSelectedRowNum() {
		return ((List<OrderInfo>)(orderService.selectTop100().get("list"))).size();
	}
	

}