from selenium import webdriver
from selenium.webdriver.firefox.options import Options
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException
from selenium.webdriver.common.by import By
#all are selenium library parts imported seperately to make it shorter to use in code. almost all are self explanatory

gout=["",""]
mrout=["",""]


options = Options()
options.binary_location = r'C:\Program Files\Mozilla Firefox\firefox.exe'
driver = webdriver.Firefox(options=options)
driver.get('https://www.ncbi.nlm.nih.gov/nuccore/PQIB02000001.1')

#waiting for page to load
try:
    wait = WebDriverWait(driver, timeout=100)
    typing_completed = wait.until(EC.invisibility_of_element_located((By.XPATH,"/html/body/div[3]/span[1]")))
    if typing_completed:
        print("page loaded")
        genes=driver.find_elements(By.XPATH,'//*[contains(@id, "feature_PQIB02000001.1_gene")]')
        print(len(genes))
        gcsv=open("gene.txt",'w')
        gnum=0
        for gene in genes:
            mrnatest=driver.find_element(By.ID,"feature_PQIB02000001.1_mRNA_"+str(gnum)).text
            for line in mrnatest.split("\n"):
                if "product" in line:
                    mrout[1]=line
            gnum=gnum+1
            geneo=gene.text
            for line in geneo.split("\n"):
                if "gene" in line:
                    gout[0]=line
                    
                if "locus" in line:
                    gout[1]=line
                    
                    gcsv.writelines(gout)
                    gcsv.write(",")
                    gcsv.write(mrout[1])
                    gcsv.write("\n")
        mrnas=driver.find_elements(By.XPATH,'//*[contains(@id, "feature_PQIB02000001.1_mRNA")]')
        print(len(mrnas))
        mrcsv=open("mr.txt",'w')
        for mrna in mrnas:
            mrnao=mrna.text
            for line in mrnao.split("\n"):
                if "locus" in line:
                    mrout[0]=line
                if "product" in line:
                    mrout[1]=line
                    mrcsv.writelines(mrout)
                    mrcsv.write("\n")



except TimeoutException:
    print("Timed out waiting for data load!")
finally:
    driver.quit()
