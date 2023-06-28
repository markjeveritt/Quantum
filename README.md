# Quantum

For driver routines please see https://github.com/markjeveritt/QuantumCommandLine

This code base contains library code to accompany our book on Quantum Mechanics.

 If this code is used, please cite:
    Quantum Mechanics
    Mark Everitt, Kieran N. Bjergstrom, Stephen Duffus
    Wiley (2023)
    ISBN-10 ‏ : ‎ 1119829879
    ISBN-13 ‏ : ‎ 978-1119829874
 
 @book{EverittQuantumMechanics2023,
    title={Quantum Mechanics},
    author={Everitt, Mark and Bjergstrom, Kieran N. and Duffus, Stephen},
    publisher={Wiley},
    year={2023},
    pages={448},
    isbn={978-1119829874},
    isbn10={1119829879},
 }
 
Neither the drivers nor library should be considered mature, stable or fit for purpose in this release.

The primary purpose of this release is pedagogy.
 
The fact that we are able to reproduce a number of published results does provide confidence that what is presented in this release is useful, tested and reasonably trustworthy.

The purpose of the effort was to show what could be done to develop within one week a library that would explain the development process and successfully run the driver code in Chapter 8 of the book to reproduce collapse and revival behaviour of the Jaynes–Cummings model.
 
I also wanted to make the library self-contained so advantage was not made of built in protocols such as AdditiveArithmetic or the Numerics package that was released shortly after the first draft of the code was completed.
 
Good practice such as logging has yet to be included and no attempt has been made to properly optimise any of the methods. In addition features such as tensor product need generalisation. In short there is much room for improvement.
 
That said the code is usable and should enable rapid solution of even quite complex problems. Feedback is welcome on how to improve the code, especially at this stage of immaturity where good suggestions are most likely to result in substantial improvements.
 
The remaining code in this folder was added after the code for chapter 8 was complete and contains the source for the cover and all other figures where computation was necessary. This should enable the reader to check the validity and reproduce those results and to preform computational experiments to explore the physics beyond the content of the text.
 
Data is generally produced in tab delimited text for plotting in third party packages such as gnuplot or pgfplots.
 
My plan is to now evaluate and develop this code base into a fully functional library. Some important design choices need to be made (such as the potential to adopt Numerics) and a careful evolution is planned before a final suitable community release is made.
