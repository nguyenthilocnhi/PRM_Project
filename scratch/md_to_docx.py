import pypandoc
import sys
import os

try:
    print("Downloading pandoc...")
    pypandoc.download_pandoc()
    print("Pandoc downloaded successfully.")
except Exception as e:
    print("Error downloading pandoc:", e)

md1 = "docs/Report1_Project_Introduction.md"
md2 = "docs/Report2_Project_Management_Plan.md"
md3 = "docs/Report3_Software_Requirement_Specification.md"
md4 = "docs/Report4_Software_Design_Document.md"
md5 = "docs/Report5_Software_Test_Documentation.md"
md6 = "docs/Report6_Software_User_Guides.md"
md7 = "docs/Report7_Capstone_Project_Document.md"

out1 = "docs/Report1_Project_Introduction.docx"
out2 = "docs/Report2_Project_Management_Plan.docx"
out3 = "docs/Report3_Software_Requirement_Specification.docx"
out4 = "docs/Report4_Software_Design_Document.docx"
out5 = "docs/Report5_Software_Test_Documentation.docx"
out6 = "docs/Report6_Software_User_Guides.docx"
out7 = "docs/Report7_Capstone_Project_Document.docx"

print("Converting", md1, "to", out1)
pypandoc.convert_file(md1, 'docx', outputfile=out1)

print("Converting", md2, "to", out2)
pypandoc.convert_file(md2, 'docx', outputfile=out2)

print("Converting", md3, "to", out3)
pypandoc.convert_file(md3, 'docx', outputfile=out3)

print("Converting", md4, "to", out4)
pypandoc.convert_file(md4, 'docx', outputfile=out4)

print("Converting", md5, "to", out5)
pypandoc.convert_file(md5, 'docx', outputfile=out5)

print("Converting", md6, "to", out6)
pypandoc.convert_file(md6, 'docx', outputfile=out6)

print("Converting", md7, "to", out7)
pypandoc.convert_file(md7, 'docx', outputfile=out7)

print("Conversion complete!")
