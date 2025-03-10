# 🖥️ Windows PC Health Check Script  

This PowerShell script helps you **check the health of a used Windows computer before buying**. It provides a **detailed system report** with a **rating** (Very Bad, Bad, Normal, Good, Excellent).  

## 🚀 Features  
✅ **CPU, RAM, Storage, GPU Details**  
✅ **Battery Health (if applicable)**  
✅ **Windows Version & Activation Status**  
✅ **S.M.A.R.T. Disk Health Check**  
✅ **Final Rating System (Very Bad to Excellent)**  

## 📌 How to Run  
Open **PowerShell (Admin)** and run this **one-liner command**:  
```powershell
irm "https://raw.githubusercontent.com/uzairdeveloper223/system-check/main/machine_check.ps1" | iex
